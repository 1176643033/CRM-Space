package com.bjpowernode.workbench.dao;

import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    int saveClue(Clue clue);

    List<Clue> getClueListByCondition(Map map);
    Integer getTotalListByCondition(Map map);

    Clue getClueById(String id);

    int update(Clue clue);

    int delete(String[] ids);

    Clue getDetailById(String id);
}
