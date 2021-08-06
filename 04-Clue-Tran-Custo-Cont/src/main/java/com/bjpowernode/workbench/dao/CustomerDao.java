package com.bjpowernode.workbench.dao;

import com.bjpowernode.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    Customer getCustomerByName(String name);

    int save(Customer customer);

    List<String> getCustomerNameByLikeName(String name);

    Customer getById(String id);
}
