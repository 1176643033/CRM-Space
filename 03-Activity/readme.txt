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
------------------------------------------------------------------------------------------------------------------

Day03(2021-07-21):
    1.添加LoginFilter,解决非法访问问题
    2.整理java/setting的dao、controller、service
    3.三个配置文件配置workbench相关的dao、controller、service
------------------------------------------------------------------------------------------------------------------

Day04(2021-07-22):
    1.编写市场活动页面jsp
    2.编写创建Activity模态窗口以及后端逻辑(getUserList.do、save.do)
    3.编写分页查询Activity(pageList.do)
    4.建立PaginationVO用于接收页对象
------------------------------------------------------------------------------------------------------------------

Day05(2021-07-23):
    1.编写多条件动态查询Activity
    2.编写删除Activity模态窗口以及后端逻辑(delete.do)
       (这里涉及事务,先删除activity_remark表数据再删除activity表数据)
    3.编写修改Activity模态窗口以及后端逻辑(delete.do、update.do)
-----------------------------------------------------------------------------------------------------------------

Day05(2021-07-24):
    1.编写Activity详情页中市场活动的删、改操作
    2.编写Activity详情页中备注的增删查改操作
        (这里的删除操作和更新操作使用尽量不过后台的方式，所以有些地方逻辑不是很好，后期可以改回过后台方式)
