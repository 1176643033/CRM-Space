package com.bjpowernode.workbench.service.impl;

import com.bjpowernode.workbench.dao.CustomerDao;
import com.bjpowernode.workbench.domain.Customer;
import com.bjpowernode.workbench.service.CustomerService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class CustomerServiceImpl implements CustomerService {

    @Resource
    private CustomerDao customerDao;

    @Override
    public List<String> getCustomerName(String name) {
        return customerDao.getCustomerNameByLikeName(name);
    }

    @Override
    public Customer getById(String id) {
        return customerDao.getById(id);
    }
}
