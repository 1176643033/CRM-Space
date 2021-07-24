package com.bjpowernode;

import com.bjpowernode.utils.DateTimeUtil;
import com.bjpowernode.utils.MD5Util;
import org.junit.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class MyTest {

    @Test
    public void test01(){
        //验证失效时间
        //失效时间
        String expireTime = "2012-08-30 10:10:10";
        //调用工具包获取当前系统时间
        String currentTime = DateTimeUtil.getSysTime();

        int count = expireTime.compareTo(currentTime);//大于0时表示还为失效
        System.out.println(count);
    }

    @Test
    public void test02(){
        String lockState="0";
        if ("1".equals(lockState)){
            System.out.println("启用");
        }else{
            System.out.println("禁用");
        }
    }

    @Test
    public void test0(){
        String pwd="123";
        pwd = MD5Util.getMD5(pwd);
        System.out.println(pwd);
    }



}
