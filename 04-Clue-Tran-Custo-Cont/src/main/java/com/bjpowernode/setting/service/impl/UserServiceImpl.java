package com.bjpowernode.setting.service.impl;

import com.bjpowernode.setting.dao.UserDao;
import com.bjpowernode.setting.domain.User;
import com.bjpowernode.exception.LoginException;
import com.bjpowernode.setting.service.UserService;
import com.bjpowernode.utils.DateTimeUtil;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class UserServiceImpl implements UserService  {
    //引用类型的自动注入@Autowired, @Resource
    @Resource
    private UserDao userDao;


    @Override
   public User login(User user, String ip) throws LoginException {
        user = userDao.queryUser(user);
        if (user == null){
            //抛出用户名与密码不匹配异常
            throw new LoginException("账户密码不匹配");

            //账号与密码都匹配 才进行下面步骤
        } else if(user.getExpireTime().compareTo(DateTimeUtil.getSysTime()) < 0){
            //1.获取当前用户的失效时间与工具类获取到的当前时间进行比较
            throw new LoginException("你的账户已失效");
        } else if( !"".equals(user.getAllowIps() )){
            //2.比较是否在允许登录IP范围内(如果为空时表示不限制任何ip登录)
            if(!user.getAllowIps().contains(ip)){
                throw new LoginException("不在可登录IP范围内");
            }
        }else if (!"1".equals(user.getLockState())){
            //3.判断是否为锁住状态
            throw new LoginException("您的账户已锁定,请联系管理员");
        }


        return userDao.queryUser(user);
   }

    @Override
    public List<User> getUserList() {
        return userDao.getUserList();
    }
}
