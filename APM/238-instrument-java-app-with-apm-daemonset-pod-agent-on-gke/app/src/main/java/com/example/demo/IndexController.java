package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class IndexController {

  @GetMapping("/")
  public String index(@RequestParam(name="name", required=false, defaultValue="anonymous") String name, Model model) {
    model.addAttribute("name", name);  
    return "index";
  }
}