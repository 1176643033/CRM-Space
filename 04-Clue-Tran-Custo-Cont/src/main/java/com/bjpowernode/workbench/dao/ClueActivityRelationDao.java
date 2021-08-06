package com.bjpowernode.workbench.dao;

import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.ClueActivityRelation;

import java.util.List;
import java.util.Map;

public interface ClueActivityRelationDao {

    boolean unbound(String id);

    int bound(ClueActivityRelation relation);

    List<ClueActivityRelation> getListByClueId(String clueId);
}
