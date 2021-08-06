package com.bjpowernode.workbench.service;

import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    boolean save(Activity activity);
    PaginationVO<Activity> pageList(Map<String, Object> map);

    boolean deleteActivity(String[] ids);

    Activity getActivityById(String id);

    boolean updateActivity(Activity activity);

    Activity getDetailById(String id);

    List<ActivityRemark> getActivityRemarkById(String activityId);

    boolean deleteRemark(String id);

    boolean saveRemark(ActivityRemark remark);

    boolean updateRemark(ActivityRemark remark);

    List<Activity> getActivityListByClueId(String clueId);

    List<Activity> getActivityListForClue(Map<String, Object> param);

    List<Activity> getActivityListInRelation(Map<String, Object> param);

    List<Activity> getListByLikeName(String condition);
}
