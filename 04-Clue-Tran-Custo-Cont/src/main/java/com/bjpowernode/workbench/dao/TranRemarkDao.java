package com.bjpowernode.workbench.dao;


import com.bjpowernode.workbench.domain.TranRemark;

import java.util.List;

public interface TranRemarkDao {

    int deleteByTranIds(String[] tid);

    List<TranRemark> getTranRemarkById(String tranId);

    int saveRemark(TranRemark remark);

    int updateRemark(TranRemark remark);

    int deleteRemark(String id);
}
