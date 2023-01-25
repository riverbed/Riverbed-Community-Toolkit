package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import java.lang.Thread;  

@Controller
public class OrdersController {

  @GetMapping("/Orders")
  public String index() {
    try {  
        Thread.sleep(3000);  
    } catch (Exception e)   
    {  
        System.err.println(e);  
    } 
    return "index";
  }
}
