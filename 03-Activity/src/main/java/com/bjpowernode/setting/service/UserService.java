package com.bjpowernode.setting.service;

import com.bjpowernode.setting.domain.User;
import com.bjpowernode.exception.LoginException;

import java.util.List;

public interface UserService {
    User login(User user, String ip) throws LoginException;
    List<User> getUserList();
}
