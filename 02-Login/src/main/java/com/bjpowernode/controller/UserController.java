package com.bjpowernode.controller;

import com.bjpowernode.domain.User;
import com.bjpowernode.service.UserService;
import com.bjpowernode.utils.MD5Util;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/user")
public class UserController {

    //引用类型的自动注入@Autowired, @Resource
    @Resource
    private UserService userService;

    @RequestMapping("/login.do")
    @ResponseBody
    public Map addStudent(User user, HttpServletRequest request){

        Map<String,Object> map = new HashMap<String,Object>();

        //获取密码的MD5形式
        user.setLoginPwd(MD5Util.getMD5(user.getLoginPwd()));
        String ip = request.getRemoteAddr();

        try{
            user = userService.login(user,ip);
            //如果有密码不匹配等不符合要求service层抛出异常,就不会以下代码
            request.getSession().setAttribute("user",user);
            map.put("success","true");
        }catch (Exception e){
            //System.out.println("=============捕捉到异常=============");
            //执行到这时表示业务层验证登录失败
            map.put("success",false);
            map.put("msg",e.getMessage());
        }

        System.out.println("用户登录map信息: "+map);

        return map;//框架会自动转为json格式
    }
}
