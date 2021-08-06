package com.bjpowernode.web.listener;

import com.bjpowernode.setting.domain.DicValue;
import com.bjpowernode.setting.service.DicService;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.annotation.Resource;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;


public class SysInitListener implements ServletContextListener {


    @Override
    public void contextInitialized(ServletContextEvent sce) {

        System.out.println("-----服务器处理数据字典缓存开始-----");
        ServletContext application = sce.getServletContext();
        DicService dicService = WebApplicationContextUtils.getWebApplicationContext(application).getBean(DicService.class);

        Map<String, List<DicValue>> map = dicService.getAll();
        //将mao解析为上下文域对象保存的键值对
        Set<String> set = map.keySet();
        for (String key : set){
            application.setAttribute(key, map.get(key));
        }
        System.out.println("-----服务器处理数据字典缓存结束-----");

        //设立在服务器缓存,服务器启动时解析该文件,将该文件的键值对关系处理为Java中键值对关系(map)
        Map<String,String> pMap = new HashMap<>();

        ResourceBundle rb = ResourceBundle.getBundle("Stage2Possibility");

        Enumeration<String> e = rb.getKeys();

        while(e.hasMoreElements()){
            //阶段
            String key = e.nextElement();
            //可能性
            String value = rb.getString(key);

            pMap.put(key, value);
        }
        //将map保存到服务器缓存中
        application.setAttribute("pMap",pMap);


    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {

    }
}
