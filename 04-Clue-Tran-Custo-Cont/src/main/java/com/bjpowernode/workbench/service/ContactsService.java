package com.bjpowernode.workbench.service;

import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.Contacts;

import java.util.List;


public interface ContactsService {

    List<Contacts> getListByLikeName(String condition);

    Contacts getById(String id);
}
