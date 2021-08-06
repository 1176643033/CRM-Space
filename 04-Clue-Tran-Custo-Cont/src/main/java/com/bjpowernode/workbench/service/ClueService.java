package com.bjpowernode.workbench.service;

import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.Clue;
import com.bjpowernode.workbench.domain.ClueRemark;
import com.bjpowernode.workbench.domain.Tran;

import java.util.List;
import java.util.Map;


public interface ClueService {

    boolean saveClue(Clue clue);

    PaginationVO<Clue> pageList(Map<String, Object> map);

    Clue getClueById(String id);

    boolean update(Clue clue);

    boolean delete(String[] ids);

    Clue getDetailById(String id);

    List<ClueRemark> getClueRemarkById(String clueId);

    boolean saveRemark(ClueRemark remark);

    boolean updateRemark(ClueRemark remark);

    boolean deleteRemark(String id);

    boolean unbound(String id);

    boolean bound(String cid, String[] aids);

    boolean convert(String clueId, Tran tran, String createBy);
}
