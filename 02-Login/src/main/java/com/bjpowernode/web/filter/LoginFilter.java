package com.bjpowernode.web.filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    public void destroy() {
    }

    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws ServletException, IOException {
        System.out.println("-------------------过滤器工作-----------------------");
        //先强转request和response
        HttpServletRequest request   = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;
        HttpSession session = request.getSession(false);

        /*
        //1.拦截后，通过调用请求对象读取请求包中请求行URI，了解访问的资源文件是谁
        String uri = request.getRequestURI();//【/网站名/资源文件名】如/EGOV/login.html or /EGOV/login
         */
        //获取访问的ServletPath
        String servletPath = request.getServletPath();
        System.out.println("servletPath"+servletPath);

        if (("/index.jsp".equals(servletPath)) || ("/login.jsp".equals(servletPath)) || ("/setting/user/login.do".equals(servletPath)) || (session != null && session.getAttribute("user") != null) ){
            //执行下一个过滤器，如果下面没有过滤器了则执行最终的Servlet资源
            chain.doFilter(request,response);
        }else {
            response.sendRedirect(request.getContextPath()+"/login.jsp");
        }

        //对响应过程进行过滤
        //System.out.println("Filter end ...");
    }

    public void init(FilterConfig config) throws ServletException {

    }
}
