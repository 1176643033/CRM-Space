package com.bjpowernode.workbench.service.impl;

import com.bjpowernode.utils.DateTimeUtil;
import com.bjpowernode.utils.UUIDUtil;
import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.dao.*;
import com.bjpowernode.workbench.domain.*;
import com.bjpowernode.workbench.service.ClueService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;
import java.util.zip.CRC32;

@Service
public class ClueServiceImpl implements ClueService {
    @Resource
    private ClueDao clueDao;
    @Resource
    private ClueRemarkDao clueRemarkDao;
    @Resource
    private ClueActivityRelationDao clueActivityRelationDao;
    @Resource
    private ActivityDao activityDao;

    @Resource
    private CustomerDao customerDao;
    @Resource
    private CustomerRemarkDao customerRemarkDao;

    @Resource
    private ContactsDao contactsDao;
    @Resource
    private ContactsRemarkDao contactsRemarkDao;
    @Resource
    private ContactsActivityRelationDao contactsActivityRelationDao;

    @Resource
    private TranDao tranDao;
    @Resource
    private TranHistoryDao tranHistoryDao;

    @Override
    public boolean saveClue(Clue clue) {
        return clueDao.saveClue(clue) == 1? true :false;
    }

    @Override
    public PaginationVO<Clue> pageList(Map<String, Object> map) {
        int total = clueDao.getTotalListByCondition(map);
        List<Clue> dataList = clueDao.getClueListByCondition(map);
        //创建vo对象接收
        PaginationVO<Clue> vo = new PaginationVO<Clue>();
        vo.setTotal(total);
        vo.setDataList(dataList);

        return vo;
    }

    @Override
    public Clue getClueById(String id) {
        return clueDao.getClueById(id);
    }

    @Override
    public boolean update(Clue clue) {
        return clueDao.update(clue) >= 1? true : false;
    }

    @Transactional  //这里事务属性使用默认
    @Override
    public boolean delete(String[] ids) {

        boolean flag = true;
        try {
            //先删子再删父
            clueRemarkDao.deleteByClueIds(ids);
            clueDao.delete(ids);
        } catch (Exception e) {
            //手动回滚, 这样可以让deleteActivity方法运行完
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            flag = false;
        }
        return flag;
    }

    @Override
    public Clue getDetailById(String id) {
        return clueDao.getDetailById(id);
    }

    @Override
    public List<ClueRemark> getClueRemarkById(String clueId) {
        return clueRemarkDao.getClueRemarkById(clueId);
    }

    @Override
    public boolean saveRemark(ClueRemark remark) {
        return clueRemarkDao.saveRemark(remark) >= 1 ? true : false ;
    }

    @Override
    public boolean updateRemark(ClueRemark remark) {
        return clueRemarkDao.updateRemark(remark) == 1 ? true : false;
    }

    @Override
    public boolean deleteRemark(String id) {
        return clueRemarkDao.deleteRemark(id) >= 1 ?  true : false;
    }

    @Override
    public boolean unbound(String id) {
        return clueActivityRelationDao.unbound(id);
    }

    @Transactional
    @Override
    public boolean bound(String cid, String[] aids) {
        ClueActivityRelation relation = new ClueActivityRelation();
        relation.setClueId(cid);
        try {
            for(String aid: aids){
                relation.setId(UUIDUtil.getUUID());
                relation.setActivityId(aid);
                clueActivityRelationDao.bound(relation);
            }
        } catch (Exception e) {
            //手动回滚, 这样可以让deleteActivity方法运行完
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }
        return true;
    }

    @Transactional
    @Override
    public boolean convert(String clueId, Tran tran, String createBy) {

        String createTime = DateTimeUtil.getSysTime();

        try {
            //(1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
            Clue clue = clueDao.getClueById(clueId);
            ;
            //(2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
            //这里把客户的name属性既(公司名字)看为唯一的
            Customer customer = customerDao.getCustomerByName(clue.getCompany());
            if(customer == null){
                customer = new Customer();
                customer.setId(UUIDUtil.getUUID());
                customer.setAddress(clue.getAddress());
                customer.setWebsite(clue.getWebsite());
                customer.setPhone(clue.getPhone());
                customer.setOwner(clue.getOwner());
                customer.setNextContactTime(clue.getNextContactTime());
                customer.setName(clue.getCompany());
                customer.setDescription(clue.getDescription());
                customer.setCreateTime(createTime);
                customer.setCreateBy(createBy);
                customer.setContactSummary(clue.getContactSummary());
                //添加客户
                customerDao.save(customer);
            }
            //(3) 通过线索对象提取联系人信息，保存联系人
            Contacts contacts = new Contacts();
            contacts.setId(UUIDUtil.getUUID());
            contacts.setSource(clue.getSource());
            contacts.setOwner(clue.getOwner());
            contacts.setNextContactTime(clue.getNextContactTime());
            contacts.setMphone(clue.getMphone());
            contacts.setJob(clue.getJob());
            contacts.setFullname(clue.getFullname());
            contacts.setEmail(clue.getEmail());
            contacts.setDescription(clue.getDescription());
            contacts.setCustomerId(customer.getId());
            contacts.setCreateTime(createTime);
            contacts.setCreateBy(createBy);
            contacts.setContactSummary(clue.getContactSummary());
            contacts.setAppellation(clue.getAppellation());
            contacts.setAddress(clue.getAddress());
            //添加联系人
            contactsDao.save(contacts);

            //(4) 线索备注转换到客户备注以及联系人备注
            List<CustomerRemark> customerRemarkList = null;
            List<ContactsRemark> contactsRemarkLis =null;

            List<ClueRemark> clueRemarkList = clueRemarkDao.getClueRemarkById(clueId);
            for(ClueRemark clueRemark : clueRemarkList){
                //创建客户备注对象,添加客户备注
                CustomerRemark customerRemark = new CustomerRemark();
                customerRemark.setId(UUIDUtil.getUUID());
                customerRemark.setCreateBy(createBy);
                customerRemark.setCreateTime(createTime);
                customerRemark.setCustomerId(customer.getId());
                customerRemark.setEditFlag("0");
                customerRemark.setNoteContent(clueRemark.getNoteContent());
                customerRemarkDao.save(customerRemark);

                //创建联系人备注对象,添加联系人备注
                ContactsRemark contactsRemark = new ContactsRemark();
                contactsRemark.setId(UUIDUtil.getUUID());
                contactsRemark.setCreateBy(createBy);
                contactsRemark.setCreateTime(createTime);
                contactsRemark.setContactsId(contacts.getId());
                contactsRemark.setEditFlag("0");
                contactsRemark.setNoteContent(clueRemark.getNoteContent());
                contactsRemarkDao.save(contactsRemark);
            }

            //(5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
            List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getListByClueId(clueId);
            //遍历出每一条与市场活动关联的关联关系记录
            for(ClueActivityRelation clueActivityRelation:clueActivityRelationList){
                //从每一条遍历出来的记录中取出关联的市场活动id
                String activityId = clueActivityRelation.getActivityId();
                //创建联系人与市场活动的关联关系对象 让第三步生成的联系人与市场活动做关联
                ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
                contactsActivityRelation.setId(UUIDUtil.getUUID());
                contactsActivityRelation.setActivityId(activityId);
                contactsActivityRelation.setContactsId(contacts.getId());
                //添加联系人与市场活动的关联关系
                contactsActivityRelationDao.save(contactsActivityRelation);
            }

            //(6) 如果有创建交易需求，创建一条交易
            if(tran != null && tran.getId() != "" && tran.getId() != null){
                tran.setSource(clue.getSource());
                tran.setOwner(clue.getOwner());
                tran.setNextContactTime(clue.getNextContactTime());
                tran.setDescription(clue.getDescription());
                tran.setCustomerId(customer.getId());
                tran.setContactSummary(clue.getContactSummary());
                tran.setContactsId(contacts.getId());
                tranDao.save(tran);

                //(7) 如果创建了交易，则创建一条该交易下的交易历史
                TranHistory tranHistory = new TranHistory();
                tranHistory.setId(UUIDUtil.getUUID());
                tranHistory.setCreateBy(createBy);
                tranHistory.setCreateTime(createTime);
                tranHistory.setExpectedDate(tran.getExpectedDate());
                tranHistory.setMoney(tran.getMoney());
                tranHistory.setStage(tran.getStage());
                tranHistory.setTranId(tran.getId());
                //添加交易历史
                tranHistoryDao.save(tranHistory);

            }

            //(8) 删除线索备注   这里需要改善,拼接成clueIds一次删除多个
            System.out.println("(8) 删除线索备注   这里需要改善,拼接成clueIds一次删除多个");
            clueRemarkDao.deleteByClueIds(new String[]{clueId});
            //(9) 删除线索和市场活动的关系
            for (ClueActivityRelation clueActivityRelation:clueActivityRelationList){
                clueActivityRelationDao.unbound(clueActivityRelation.getId());
            }
            //(10) 删除线索
            clueDao.delete(new String[]{clueId} );
        } catch (Exception e) {
            //手动回滚, 这样可以让deleteActivity方法运行完
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }
        return true;
    }

}
