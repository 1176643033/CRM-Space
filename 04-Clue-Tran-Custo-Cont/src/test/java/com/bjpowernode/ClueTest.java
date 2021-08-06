package com.bjpowernode;

import com.bjpowernode.workbench.dao.ClueDao;
import com.bjpowernode.workbench.dao.CustomerDao;
import com.bjpowernode.workbench.domain.Customer;
import org.junit.Test;

import javax.annotation.Resource;

public class ClueTest {
    @Resource
    public ClueDao clueDao;
    @Resource
    public CustomerDao customerDao;
    @Test
    public void testGetDetail(){

        System.out.println(customerDao.getCustomerByName(""));
    }

}
