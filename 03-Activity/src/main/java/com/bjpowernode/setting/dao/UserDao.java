package com.bjpowernode.setting.dao;

import com.bjpowernode.setting.domain.User;

import java.util.List;

public interface UserDao {
    User queryUser(User user);
    List<User> getUserList();
}
