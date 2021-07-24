package com.bjpowernode.workbench.dao;

import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkDao {
    int deleteByActivityIds(String[] aid);

    List<ActivityRemark> getActivityRemarkById(String activityId);

    int deleteRemark(String id);

    int saveRemark(ActivityRemark remark);

    int updateRemark(ActivityRemark remark);
}
