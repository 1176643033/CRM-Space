package com.bjpowernode.workbench.service;

import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.domain.Tran;
import com.bjpowernode.workbench.domain.TranHistory;
import com.bjpowernode.workbench.domain.TranRemark;

import java.util.List;
import java.util.Map;

public interface TranService {
    boolean save(Tran tran, String createTime);

    PaginationVO<Tran> pageList(Map<String, Object> map);

    Tran getById(String id);

    boolean update(Tran tran, String editTime);

    Tran getDetailById(String id);

    List<TranHistory> getHistoryListByTranId(String tranId);

    List<TranRemark> getTranRemarkById(String tranId);

    boolean saveRemark(TranRemark remark);

    boolean updateRemark(TranRemark remark);

    boolean deleteRemark(String id);

    boolean updateStage(Tran tran);

    int getTotal();


    List<Map<String, Integer>> getStageAndNum();
}
