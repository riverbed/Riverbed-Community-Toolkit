package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class LogoutController {

  @GetMapping("/Logout")
  public String index() {
    return "logout";
  }
}
