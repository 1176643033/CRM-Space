package com.bjpowernode.dao;

import com.bjpowernode.domain.Student;
import com.bjpowernode.domain.User;

public interface UserDao {
    Integer insertUser(Student student);
    User queryUser(User user);
}
