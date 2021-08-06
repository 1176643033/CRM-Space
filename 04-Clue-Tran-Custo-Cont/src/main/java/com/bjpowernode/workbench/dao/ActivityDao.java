package com.bjpowernode.workbench.dao;

import com.bjpowernode.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityDao {
    Integer save(Activity activity);
    List<Activity> getActivityListByCondition(Map map);
    Integer getTotalListByCondition(Map map);

    int deleteByIds(String[] aid);

    Activity getActivityById(String id);

    int updateActivity(Activity activity);

    Activity getDetailById(String id);

    List<Activity> getActivityListByClueId(String clueId);

    List<Activity> getActivityListForClue(Map<String,Object> param);


    List<Activity> getActivityListInRelation(Map<String,Object> param);

    List<Activity> getListByLikeName(String condition);
}
