package com.bjpowernode.workbench.service;

import com.bjpowernode.workbench.domain.Activity;
import com.bjpowernode.workbench.domain.Customer;

import java.util.List;

public interface CustomerService {
    List<String> getCustomerName(String name);

    Customer getById(String id);
}
