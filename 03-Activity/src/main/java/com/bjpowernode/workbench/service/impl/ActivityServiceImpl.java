package com.bjpowernode.workbench.service.impl;

import com.bjpowernode.setting.domain.User;
import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.dao.ActivityDao;
import com.bjpowernode.workbench.dao.ActivityRemarkDao;
import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.ActivityRemark;
import com.bjpowernode.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;

@Service
public class ActivityServiceImpl implements ActivityService {

    @Resource
    private ActivityDao activityDao;
    @Resource
    private ActivityRemarkDao activityRemarkDao;

    @Override
    public boolean save(Activity activity) {

        if (activityDao.save(activity) >= 1 ){
            return true;
        }
        return false;
    }

    @Override
    public PaginationVO<Activity> pageList(Map<String, Object> map) {
        int total = activityDao.getTotalListByCondition(map);
        List<Activity> dataList = activityDao.getActivityListByCondition(map);
        //创建vo对象接收
        PaginationVO<Activity> vo = new PaginationVO<Activity>();
        vo.setTotal(total);
        vo.setDataList(dataList);

        return vo;
    }

    @Transactional  //这里事务属性使用默认
    @Override
    public boolean deleteActivity(String[] ids) {

        boolean flag = true;
        try {
            //先删子再删父
            activityRemarkDao.deleteByActivityIds(ids);
            activityDao.deleteByIds(ids);
        } catch (Exception e) {
            //手动回滚, 这样可以让deleteActivity方法运行完
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            flag = false;
        }
        return flag;
    }

    @Override
    public Activity getActivityById(String id) {
        return activityDao.getActivityById(id);
    }

    @Override
    public boolean updateActivity(Activity activity) {
        return activityDao.updateActivity(activity) ==1 ? true : false;
    }

    @Override
    public Activity getDetailById(String id) {
        return activityDao.getDetailById(id);
    }

    @Override
    public List<ActivityRemark> getActivityRemarkById(String activityId) {
        return activityRemarkDao.getActivityRemarkById(activityId);
    }

    @Override
    public boolean deleteRemark(String id) {
        return activityRemarkDao.deleteRemark(id) >= 1 ?  true : false;
    }

    @Override
    public boolean saveRemark(ActivityRemark remark) {
        return activityRemarkDao.saveRemark(remark) == 1 ? true : false;
    }

    @Override
    public boolean updateRemark(ActivityRemark remark) {
        return activityRemarkDao.updateRemark(remark) == 1 ? true : false;
    }

}
