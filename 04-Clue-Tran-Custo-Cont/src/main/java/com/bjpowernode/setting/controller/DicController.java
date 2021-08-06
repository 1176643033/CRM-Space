package com.bjpowernode.setting.controller;

import com.bjpowernode.setting.service.DicService;
import org.springframework.stereotype.Controller;

import javax.annotation.Resource;

@Controller
public class DicController {
    @Resource
    private DicService dicService;
}
