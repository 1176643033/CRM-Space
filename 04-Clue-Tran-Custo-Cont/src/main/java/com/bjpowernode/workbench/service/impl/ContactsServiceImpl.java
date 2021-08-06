package com.bjpowernode.workbench.service.impl;

import com.bjpowernode.workbench.dao.ContactsDao;
import com.bjpowernode.workbench.domain.Contacts;
import com.bjpowernode.workbench.service.ContactsService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class ContactsServiceImpl implements ContactsService {

    @Resource
    private ContactsDao contactsDao;

    @Override
    public List<Contacts> getListByLikeName(String condition) {
        return contactsDao.getListByLikeName(condition);
    }

    @Override
    public Contacts getById(String id) {
        return contactsDao.getById(id);
    }
}
