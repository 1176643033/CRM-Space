package com.bjpowernode.service;

import com.bjpowernode.domain.User;
import com.bjpowernode.exception.LoginException;

import javax.servlet.http.HttpServletRequest;

public interface UserService {
    User login(User user, String ip) throws LoginException;
}
