CRM:
Day01(2021-06-23):

    SpringMVC: 视图层, 界面层,负责接收请求, 显示处理结果的。
    Spring： 业务层, 管理service, dao, 工具类对象的。
    Mybatis: 持久层, 访问数据库的

    用户发起请求--->SpringMVC接收--->Spring中的Service对象--->Mybatis处理数据

    实现步骤：
    1).新建maven web项目
    2).加入依赖(pom文件)
      springmvc,spring, mybatis三个框架的依赖, Jackson依赖, mysql驱动,druid连接池
      jsp, servlet依赖
    3).写web.xml
        1)注册DispatcherServlet, 目的: (1)创建springmvc容器对象, 才能创建Controller类对象。
                                       (2)创建的是Servlet, 才能接收用户的请求。
        2)注册spring的监听器: ContextLoaderListener, 目的: 创建spring的容器对象,才能创建service, dao等对象。
        3)注册字符集过滤器，解决post请求乱码的问题
        4)指定监听器加载的log4j配置文件
    4).创建包，Controller包，service，dao，实体类包名创建好(额外还可以创建vo包用于接收数据赋值给对象)。
    5).编辑springmvc，spring，mybatis, log4j2的配置文件
        1)springmvc配置文件(dispatcherServlet)
        2)spring配置文件(applicationContext)
        3)mybatis主配置文件
        4)log4j2配置文件
    6).完成测试可以按照模块调用相应Controller, 可以连接数据库实现insert操作。

存在的问题：1)静态资源访问问题，当设置使用Tomcat的默认Servlet时html会乱码
            2)暂时设置DispatcherServlet的路径为*.do
