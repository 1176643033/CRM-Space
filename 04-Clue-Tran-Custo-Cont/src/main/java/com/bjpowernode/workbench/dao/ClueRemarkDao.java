package com.bjpowernode.workbench.dao;

import com.bjpowernode.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    int deleteByClueIds(String[] cid);

    List<ClueRemark> getClueRemarkById(String clueId);

    int saveRemark(ClueRemark remark);

    int updateRemark(ClueRemark remark);

    int deleteRemark(String id);
}
