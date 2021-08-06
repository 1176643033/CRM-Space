package com.bjpowernode.workbench.controller;

import com.bjpowernode.setting.domain.User;
import com.bjpowernode.setting.service.UserService;
import com.bjpowernode.utils.DateTimeUtil;
import com.bjpowernode.utils.UUIDUtil;
import com.bjpowernode.vo.PaginationVO;
import com.bjpowernode.workbench.dao.CustomerDao;
import com.bjpowernode.workbench.domain.*;
import com.bjpowernode.workbench.service.ActivityService;
import com.bjpowernode.workbench.service.ContactsService;
import com.bjpowernode.workbench.service.CustomerService;
import com.bjpowernode.workbench.service.TranService;
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
@RequestMapping("/workbench/transaction")
public class TranController {

    @Resource
    private CustomerService customerService;
    @Resource
    private ContactsService contactsService;
    @Resource
    private ActivityService activityService;
    @Resource
    private UserService userService;
    @Resource
    private TranService tranService;

    @RequestMapping("/add.do")
    public ModelAndView add(){
        ModelAndView mv = new ModelAndView();
        mv.addObject("dataList",userService.getUserList());
        mv.setViewName("workbench/transaction/save");
        return mv;
    }

    @RequestMapping("/getActivityListByCondition.do")
    @ResponseBody
    public Map getActivityListByCondition(String condition){
        Map<String, Object> map = new HashMap<>();

        map.put("activityList",activityService.getListByLikeName(condition));
        map.put("success",true);

        return map;

    }

    @RequestMapping("/getContactsListByCondition.do")
    @ResponseBody
    public Map getContactsListByCondition(String condition){
        Map<String, Object> map = new HashMap<>();

        map.put("contactsList",contactsService.getListByLikeName(condition));
        map.put("success",true);

        return map;

    }

    @RequestMapping("/getCustomerName.do")
    @ResponseBody
    public List<String> getCustomerName(String name){

        return customerService.getCustomerName(name);
    }

    @RequestMapping("/save.do")
    public String save(Tran tran, HttpServletRequest request){
        String createTime = DateTimeUtil.getSysTime();
        tran.setCreateBy(((User)request.getSession().getAttribute("user")).getName());
        tranService.save(tran, createTime);

        return "redirect:/workbench/transaction/index.jsp";
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

        map.put("owner", request.getParameter("owner"));
        map.put("name", request.getParameter("name"));
        map.put("customerName", request.getParameter("customerName"));
        map.put("stage", request.getParameter("stage"));
        map.put("type", request.getParameter("type"));
        map.put("source", request.getParameter("source"));
        map.put("contactsName", request.getParameter("contactsName"));
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        System.out.println("===========输出map===========");
        System.out.println(map);

        PaginationVO<Tran> vo = tranService.pageList(map);

        return vo;
    }

    @RequestMapping("/edit.do")
    public ModelAndView edit(String id){
        ModelAndView mv = new ModelAndView();
        Tran tran = tranService.getById(id);
        //根据id查出该tran转发到编辑页
        mv.addObject("tran",tran);
        mv.addObject("dataList",userService.getUserList());
        mv.addObject("activityName",activityService.getActivityById(tran.getActivityId()).getName());
        mv.addObject("contactsFullName",contactsService.getById(tran.getContactsId()).getFullname());
        mv.addObject("customerName",customerService.getById(tran.getCustomerId()).getName());
        mv.setViewName("workbench/transaction/edit");
        return mv;
    }

    @RequestMapping("/update.do")
    public String update(Tran tran, HttpServletRequest request){
        String editTime = DateTimeUtil.getSysTime();
        tran.setEditBy(((User)request.getSession().getAttribute("user")).getName());
        tranService.update(tran, editTime);

        return "redirect:/workbench/transaction/index.jsp";
    }

    @RequestMapping("/detail.do")
    public ModelAndView detail(String id){
        ModelAndView mv = new ModelAndView();
        Tran tran = tranService.getDetailById(id);
        System.out.println("-------detail------取得的tran");
        System.out.println(tran);
        //根据id查出该tran转发到编辑页
        mv.addObject("tran",tran);
        mv.setViewName("workbench/transaction/detail");
        return mv;
    }

    @RequestMapping("/getHistoryListByTranId.do")
    @ResponseBody
    public Map getHistoryListByTranId(String tranId){
        Map<String,Object> map = new HashMap<>();
        map.put("dataList", tranService.getHistoryListByTranId(tranId));
        map.put("success", true);
        return map;
    }

    @RequestMapping("/getTranRemarkById.do")
    @ResponseBody
    public List<TranRemark> geTranRemarkById(String tranId){
        return tranService.getTranRemarkById(tranId);
    }

    @RequestMapping("/saveRemark.do")
    @ResponseBody
    public boolean saveRemark(TranRemark remark, HttpServletRequest request){

        remark.setId(UUIDUtil.getUUID());
        remark.setCreateBy( ((User)request.getSession().getAttribute("user")).getName() );
        remark.setCreateTime(DateTimeUtil.getSysTime());
        remark.setEditFlag("0");
        return tranService.saveRemark(remark);
    }

    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public boolean updateRemark(TranRemark remark,HttpServletRequest request){
        remark.setEditFlag("1");
        remark.setEditBy(((User)request.getSession().getAttribute("user")).getName());
        remark.setEditTime(DateTimeUtil.getSysTime());
        return tranService.updateRemark(remark);
    }

    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public boolean deleteRemark(String id){
        return tranService.deleteRemark(id);
    }

    @RequestMapping("/changeStage.do")
    @ResponseBody
    public Map changeStage(Tran tran, HttpServletRequest request){
        Map<String,Object> map = new HashMap<>();

        tran.setEditBy(((User)request.getSession().getAttribute("user")).getName());
        tran.setEditTime(DateTimeUtil.getSysTime());
        map.put("success",tranService.updateStage(tran));
        map.put("tran",tran);

        return map;
    }

    @RequestMapping("getCharts.do")
    @ResponseBody
    public Map getCharts(){
        Map<String,Object> map =new HashMap<>();
        //1.获取总条数并封装
        int max = tranService.getTotal();
        //2.获取所有阶段相应的数量封装
        List<Map<String,Integer>> dataList = tranService.getStageAndNum();
        map.put("max",max);
        map.put("dataList",dataList);

        return map;
    }
}
