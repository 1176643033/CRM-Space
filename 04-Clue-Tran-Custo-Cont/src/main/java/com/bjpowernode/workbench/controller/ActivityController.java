package com.bjpowernode.workbench.controller;

import com.bjpowernode.setting.domain.User;
import com.bjpowernode.setting.service.UserService;
import com.bjpowernode.utils.DateTimeUtil;
import com.bjpowernode.utils.UUIDUtil;
import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.ActivityRemark;
import com.bjpowernode.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/workbench/activity")
public class ActivityController {

    @Resource
    private ActivityService activityService;
    @Resource
    private UserService userService;

    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        return userService.getUserList();
    }

    @RequestMapping("/save.do")
    @ResponseBody
    public boolean saveActivity(Activity activity,HttpServletRequest request){

        activity.setId(UUIDUtil.getUUID());
        activity.setCreateTime(DateTimeUtil.getSysTime());
        activity.setCreateBy(((User)request.getSession().getAttribute("user")).getName());
        
        return activityService.save(activity);
    }

    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVO pageList(HttpServletRequest request){
        Map<String,Object> map = new HashMap<>();

        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        int pageNo = Integer.valueOf(pageNoStr);
        int pageSize = Integer.valueOf(pageSizeStr);
        int skipCount = (pageNo-1)*pageSize;

        map.put("name", request.getParameter("name"));
        map.put("owner", request.getParameter("owner"));
        map.put("startDate", request.getParameter("startDate"));
        map.put("endDate", request.getParameter("endDate"));
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        /*
            前端要: 市场活动信息列表、查询的总条数

            业务层拿到上面这两个数据时有两种方式：map、VO
            因为会多次用到查询这种方式所以这里用vo形式
         */
        PaginationVO<Activity> vo = activityService.pageList(map);

        return vo;
    }

    @RequestMapping("/delete.do")
    @ResponseBody
    public boolean deleteActivity(String[] id){
        return activityService.deleteActivity(id);
    }

    @RequestMapping("/getActivityById.do")
    @ResponseBody
    public Map getActivityById(String id){
        Map<String,Object> map = new HashMap<>();
        map.put("activity",activityService.getActivityById(id));
        map.put("userList",userService.getUserList());
        return map;
    }

    @RequestMapping("/update.do")
    @ResponseBody
    public boolean updateActivity(Activity activity){
        activity.setEditTime(DateTimeUtil.getSysTime());
        return activityService.updateActivity(activity);
    }

    @RequestMapping("/detail.do")
    public ModelAndView detail(String id){
        ModelAndView mv = new ModelAndView();
        mv.addObject("activity",activityService.getDetailById(id));
        mv.addObject("remarkList",null);
        mv.setViewName("workbench/activity/detail");
        return mv;
    }

    @RequestMapping("/getActivityRemarkById.do")
    @ResponseBody
    public List<ActivityRemark> getActivityRemarkById(String activityId){
        return activityService.getActivityRemarkById(activityId);
    }

    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public boolean deleteRemark(String id){
        return activityService.deleteRemark(id);
    }

    @RequestMapping("/saveRemark.do")
    @ResponseBody
    public Map saveRemark(ActivityRemark remark, HttpServletRequest request){

        Map<String,Object> map = new HashMap<>();
        remark.setId(UUIDUtil.getUUID());
        remark.setCreateBy( ((User)request.getSession().getAttribute("user")).getName() );
        remark.setCreateTime(DateTimeUtil.getSysTime());
        remark.setEditFlag("0");

        if(activityService.saveRemark(remark)){
            map.put("remark",remark);
            map.put("success",true);
        }else {
            map.put("success",false);
        }
        return map;
    }

    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public Map updateRemark(ActivityRemark remark,HttpServletRequest request){
        Map<String,Object> map = new HashMap<>();
        remark.setEditFlag("1");
        remark.setEditBy(((User)request.getSession().getAttribute("user")).getName());
        remark.setEditTime(DateTimeUtil.getSysTime());
        System.out.println("--------------"+remark);
        if(activityService.updateRemark(remark)){
            map.put("remark",remark);
            map.put("success",true);
        }else {
            map.put("success",false);
        }
        return map;
    }

}
