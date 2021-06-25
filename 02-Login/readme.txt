CRM:
Day02(2021-06-25):

    1.编写CRM.js工具用于表单组件校验
    2.login.jsp中完成登录操作
        1)组件验非空
        2)ajax通过post方式发起请求
        3)如果登录操作中后段和前端都成功则跳转到workbench/index页面
        4)失败时获取msg,给出相应提示
    3.编写LoginException,用于获取登录失败时的信息
    4.UserDao增加queryUser方法:select * from tbl_user where loginAct=#{loginAct} and loginPwd=#{loginPwd}
    5.UserServiceImpl调用调用UserDao的queryUser方法后
        继续校验账户密码是否匹配,是否为锁定状态,是否允许IP地址,是否过有效期
            public User login(User user, String ip) throws LoginException
        有异常时往上抛,以至于UserController能获取到登录失败的原因
    6.USerController中编写方法处理登录业务
        public Map addStudent(User user, HttpServletRequest request)
      登录成功时放回值map中只有success, 失败时有success以及msg