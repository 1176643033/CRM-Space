package com.bjpowernode.workbench.service.impl;

import com.bjpowernode.utils.UUIDUtil;
import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.dao.CustomerDao;
import com.bjpowernode.workbench.dao.TranDao;
import com.bjpowernode.workbench.dao.TranHistoryDao;
import com.bjpowernode.workbench.dao.TranRemarkDao;
import com.bjpowernode.workbench.domain.*;
import com.bjpowernode.workbench.service.TranService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service
public class TranServiceImpl implements TranService {

    @Resource
    private CustomerDao customerDao;
    @Resource
    private TranDao tranDao;
    @Resource
    private TranHistoryDao tranHistoryDao;
    @Resource
    private TranRemarkDao tranRemarkDao;


    @Transactional
    @Override
    public boolean save(Tran tran, String createTime) {

        try {
            //1.因为前端出来的customerId是公司名字,先查出该公司Id重新赋值给tran.customerId
            Customer customer = customerDao.getCustomerByName(tran.getCustomerId());
            // //如果没有从数据库中查出该公司则需要新建customer
            if(customer == null){
                customer = new Customer();
                customer.setId(UUIDUtil.getUUID());
                customer.setName(tran.getCustomerId());
                customer.setCreateBy(tran.getCreateBy());
                customer.setCreateTime(createTime);
                customer.setContactSummary(tran.getContactSummary());
                customer.setNextContactTime(tran.getNextContactTime());
                customer.setOwner(tran.getOwner());
                //新增customer
                customerDao.save(customer);
            }
            String customerId = customer.getId();
            tran.setCustomerId(customerId);

            //2.给tran赋值,使得完整
            tran.setId(UUIDUtil.getUUID());
            tran.setCreateTime(createTime);

            //3.保存该交易
            tranDao.save(tran);

            //4.新增交易历史并保存
            TranHistory tranHistory =new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setTranId(tran.getId());
            tranHistory.setStage(tran.getStage());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setCreateTime(createTime);
            tranHistory.setCreateBy(tran.getCreateBy());
            tranHistoryDao.save(tranHistory);
        } catch (Exception e) {
            //手动回滚, 这样可以让deleteActivity方法运行完
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }

        return true;
    }

    @Override
    public PaginationVO<Tran> pageList(Map<String, Object> map) {
        int total = tranDao.getTotalListByCondition(map);
        List<Tran> dataList = tranDao.getTranListByCondition(map);
        //创建vo对象接收
        PaginationVO<Tran> vo = new PaginationVO<Tran>();
        vo.setTotal(total);
        vo.setDataList(dataList);

        return vo;
    }

    @Override
    public Tran getById(String id) {
        return tranDao.getById(id);
    }

    @Transactional
    @Override
    public boolean update(Tran tran, String editTime) {

        try {
            //1.因为前端出来的customerId是公司名字,先查出该公司Id重新赋值给tran.customerId
            Customer customer = customerDao.getCustomerByName(tran.getCustomerId());
            // //如果没有从数据库中查出该公司则需要新建customer
            if(customer == null){
                customer = new Customer();
                customer.setId(UUIDUtil.getUUID());
                customer.setName(tran.getCustomerId());
                customer.setCreateBy(tran.getEditBy());
                customer.setCreateTime(editTime);
                customer.setContactSummary(tran.getContactSummary());
                customer.setNextContactTime(tran.getNextContactTime());
                customer.setOwner(tran.getOwner());
                //新增customer
                customerDao.save(customer);
            }
            String customerId = customer.getId();
            tran.setCustomerId(customerId);

            //2.给tran赋更改时间值,使得完整
            tran.setEditTime(editTime);

            //3.保存该交易
            tranDao.update(tran);

            //4.新增交易历史并保存
            TranHistory tranHistory =new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setTranId(tran.getId());
            tranHistory.setStage(tran.getStage());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setCreateTime(editTime);
            tranHistory.setCreateBy(tran.getEditBy());
            tranHistoryDao.save(tranHistory);
        } catch (Exception e) {
            //手动回滚, 这样可以让deleteActivity方法运行完
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }

        return true;
    }

    @Override
    public Tran getDetailById(String id) {
        return tranDao.getDetailById(id);
    }

    @Override
    public List<TranHistory> getHistoryListByTranId(String tranId) {
        return tranHistoryDao.getHistoryListByTranId(tranId);
    }

    @Override
    public List<TranRemark> getTranRemarkById(String tranId) {
        return tranRemarkDao.getTranRemarkById(tranId);
    }

    @Override
    public boolean saveRemark(TranRemark remark) {
        return tranRemarkDao.saveRemark(remark) >= 1? true :false;
    }

    @Override
    public boolean updateRemark(TranRemark remark) {
        return tranRemarkDao.updateRemark(remark) >= 1? true :false;
    }

    @Override
    public boolean deleteRemark(String id) {
        return tranRemarkDao.deleteRemark(id) >=1 ? true : false;
    }

    @Transactional
    @Override
    public boolean updateStage(Tran tran) {

        try {
            //1.更改tran的editTime  ID和阶段和editBy在controller
            tranDao.updateStage(tran);
            //2.新增交易历史
            TranHistory tranHistory =new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setTranId(tran.getId());
            tranHistory.setStage(tran.getStage());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setCreateTime(tran.getEditTime());
            tranHistory.setCreateBy(tran.getEditBy());
            tranHistoryDao.save(tranHistory);
        } catch (Exception e) {
            //手动回滚, 这样可以让deleteActivity方法运行完
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            return false;
        }

        return true;
    }

    @Override
    public int getTotal() {
        return tranDao.getTotal();
    }

    @Override
    public List<Map<String, Integer>> getStageAndNum() {
        return tranDao.getStageAndNum();
    }


}
