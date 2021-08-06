package com.bjpowernode.workbench.controller;

import com.bjpowernode.setting.domain.User;
import com.bjpowernode.setting.service.UserService;
import com.bjpowernode.utils.DateTimeUtil;
import com.bjpowernode.utils.UUIDUtil;
import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.domain.ActivityRemark;
import com.bjpowernode.workbench.domain.Clue;
import com.bjpowernode.workbench.domain.ClueRemark;
import com.bjpowernode.workbench.domain.Tran;
import com.bjpowernode.workbench.service.ActivityService;
import com.bjpowernode.workbench.service.ClueService;
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
@RequestMapping("/workbench/clue")
public class ClueController {
    @Resource
    private ClueService clueService;
    @Resource
    private UserService userService;
    @Resource
    private ActivityService activityService;


    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        //这里其实应该调clueService,clueService调userDao的
        return userService.getUserList();
    }

    @RequestMapping("/saveClue.do")
    @ResponseBody
    public boolean saveClue(Clue clue, HttpServletRequest request){

        clue.setId(UUIDUtil.getUUID());
        clue.setCreateBy(((User)request.getSession().getAttribute("user")).getName());
        clue.setCreateTime(DateTimeUtil.getSysTime());
        System.out.println("-----------标识---------------"+clue);
        return clueService.saveClue(clue);
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

        map.put("fullname", request.getParameter("fullname"));
        System.out.println("--------------"+request.getParameter("fullname"));
        map.put("company", request.getParameter("company"));
        map.put("phone", request.getParameter("phone"));
        map.put("source", request.getParameter("source"));
        map.put("owner", request.getParameter("owner"));
        map.put("mphone", request.getParameter("mphone"));
        map.put("state", request.getParameter("state"));
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        PaginationVO<Clue> vo = clueService.pageList(map);

        return vo;
    }

    @RequestMapping("/getClueById.do")
    @ResponseBody
    public Map getClueById(String id){
        Map<String,Object> map = new HashMap<>();
        map.put("clue",clueService.getClueById(id));
        map.put("userList",userService.getUserList());
        return map;
    }

    @RequestMapping("/update.do")
    @ResponseBody
    public boolean update(Clue clue, HttpServletRequest request){
        clue.setEditBy(((User)request.getSession().getAttribute("user")).getName());
        clue.setEditTime(DateTimeUtil.getSysTime());
        System.out.println("==================="+clue);
        return clueService.update(clue);
    }

    @RequestMapping("/delete.do")
    @ResponseBody
    public boolean delete(String[] id){
        return clueService.delete(id);
    }

    @RequestMapping("/detail.do")
    public ModelAndView detail(String id){
        ModelAndView mv = new ModelAndView();
        mv.addObject("clue",clueService.getDetailById(id));
        mv.addObject("remarkList",null);
        mv.setViewName("workbench/clue/detail");
        return mv;
    }

    @RequestMapping("/getClueRemarkById")
    @ResponseBody
    public List<ClueRemark> getActivityRemarkById(String clueId){
        return clueService.getClueRemarkById(clueId);
    }

    @RequestMapping("/saveRemark.do")
    @ResponseBody
    public boolean saveRemark(ClueRemark remark, HttpServletRequest request){

        remark.setId(UUIDUtil.getUUID());
        remark.setCreateBy( ((User)request.getSession().getAttribute("user")).getName() );
        remark.setCreateTime(DateTimeUtil.getSysTime());
        remark.setEditFlag("0");
        return clueService.saveRemark(remark);
    }

    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public boolean updateRemark(ClueRemark remark,HttpServletRequest request){
        remark.setEditFlag("1");
        remark.setEditBy(((User)request.getSession().getAttribute("user")).getName());
        remark.setEditTime(DateTimeUtil.getSysTime());
        return clueService.updateRemark(remark);
    }

    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public boolean deleteRemark(String id){
        return clueService.deleteRemark(id);
    }

    @RequestMapping("/getActivityListByClueId.do")
    @ResponseBody
    public Map getActivityListByClueId(String clueId){
        Map<String, Object> map = new HashMap<>();
        map.put("activityList",activityService.getActivityListByClueId(clueId));
        map.put("success", true);
        return map;
    }

    @RequestMapping("/unbound.do")
    @ResponseBody
    public Map unbound(String id){
        Map<String, Object> map = new HashMap<>();
        map.put("success",clueService.unbound(id));
        return map;
    }

    @RequestMapping("/getActivityList.do")
    @ResponseBody
    public Map getActivityList(String condition, String clueId){
        Map<String, Object> map = new HashMap<>();
        Map<String,Object> param = new HashMap<>();
        param.put("condition",condition);
        param.put("clueId",clueId);
        map.put("activityList",activityService.getActivityListForClue(param));
        map.put("success", true);
        return map;
    }

    @RequestMapping("/bound.do")
    @ResponseBody
    public Map bound(String cid,String[] aid){
        Map<String,Object> map = new HashMap<>();
        map.put("success",clueService.bound(cid,aid));
        return map;
    }

    @RequestMapping("/getActivityListInRelation.do")
    @ResponseBody//
    public Map getActivityListInRelation(String condition,String clueId){
        Map<String, Object> map = new HashMap<>();
        Map<String,Object> param = new HashMap<>();
        param.put("clueId",clueId);
        param.put("condition",condition);
        map.put("activityList",activityService.getActivityListInRelation(param));
        map.put("success", true);
        return map;
    }

    @RequestMapping("/convert.do")
    @ResponseBody
    public ModelAndView convert(Tran tran,String clueId,HttpServletRequest request){
        ModelAndView mv = new ModelAndView();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        if(tran.getActivityId() != ""){
            tran.setId(UUIDUtil.getUUID());
            tran.setCreateTime(DateTimeUtil.getSysTime());
            tran.setCreateBy(createBy);
        }

        mv.setViewName("workbench/clue/index");
        return mv;
    }
}
