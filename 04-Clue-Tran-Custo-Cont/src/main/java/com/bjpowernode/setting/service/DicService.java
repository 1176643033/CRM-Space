package com.bjpowernode.setting.service;

import com.bjpowernode.setting.domain.DicValue;

import java.util.List;
import java.util.Map;

public interface DicService {
    Map<String, List<DicValue>> getAll();
}
