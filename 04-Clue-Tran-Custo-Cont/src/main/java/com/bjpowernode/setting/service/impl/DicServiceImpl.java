package com.bjpowernode.setting.service.impl;

import com.bjpowernode.setting.dao.DicTypeDao;
import com.bjpowernode.setting.dao.DicValueDao;
import com.bjpowernode.setting.domain.DicType;
import com.bjpowernode.setting.domain.DicValue;
import com.bjpowernode.setting.service.DicService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import javax.xml.stream.events.DTD;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DicServiceImpl implements DicService {

    @Resource
    private DicValueDao dicValueDao;
    @Resource
    private DicTypeDao dicTypeDao;

    @Override
    public Map<String, List<DicValue>> getAll() {
        Map<String, List<DicValue>> map = new HashMap<>();

        //将字典类型列表取出
        List<DicType> dicTypeList = dicTypeDao.getTypeList();

        //将字典类型列表遍历
        for(DicType dicType:dicTypeList){
            //取得每一种类型的字典类型编码
            String code = dicType.getCode();
            //根据每一个字典类型来取得字典值列表
            List<DicValue> dicValueList = dicValueDao.getListByCode(code);

            map.put(code+"List", dicValueList);
        }
        return map;
    }
}
