package com.bjpowernode.controller;

import com.bjpowernode.dao.StudentDao;
import com.bjpowernode.domain.Student;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;

@Controller
@RequestMapping("/student")
public class StudentController {

    //测试阶段跳过service调用dao层
    //引用类型的自动注入@Autowired, @Resource
    @Resource
    private StudentDao studentDao;

    @RequestMapping("/add")
    public ModelAndView addStudent(Student student){
        System.out.println("学生Controller输出");
        ModelAndView mv = new ModelAndView();
        if(studentDao.insertStudent(student) != 0){
            mv.addObject("msg","添加学生成功");
        }else {
            mv.addObject("msg","添加学生失败");
        }
        mv.setViewName("show");
        return mv;
    }
}
