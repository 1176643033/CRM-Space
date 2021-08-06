package com.bjpowernode.workbench.dao;

import com.bjpowernode.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int save(Tran tran);

    int getTotalListByCondition(Map<String, Object> map);

    List<Tran> getTranListByCondition(Map<String, Object> map);

    Tran getById(String id);

    int update(Tran tran);

    Tran getDetailById(String id);

    int updateStage(Tran tran);

    int getTotal();

    List<Map<String, Integer>> getStageAndNum();
}
