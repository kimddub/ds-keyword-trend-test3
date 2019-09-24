package com.example.demo.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class HomeController {
	String urlStr = "http://qt.some.co.kr/TrendMap/JSON/ServiceHandler?lang=ko&source=blog&startDate=20190901&endDate=20190909&keyword=%EB%82%98%EC%9D%B4%ED%82%A4&topN=100&cutOffFrequencyMin=0&cutOffFrequencyMax=0&period=0&invertRowCol=on&start_weekday=SUNDAY&categorySetName=SM&command=GetAssociationTransitionBySentiment";
	
	@RequestMapping("/home")
	public String showMain(HttpServletRequest rq, HttpServletResponse rs) {
		
		return "home/main";
	}
	
	@RequestMapping("/home/getData")
	@ResponseBody
	public String getData() {
		String result = "";
		
		BufferedReader br = null;
		
        try{            
            URL url = new URL(urlStr);
            HttpURLConnection urlconnection = (HttpURLConnection) url.openConnection();
            urlconnection.setRequestMethod("GET");
            br = new BufferedReader(new InputStreamReader(urlconnection.getInputStream(),"UTF-8"));
            
            String line;
            
            while((line = br.readLine()) != null) {
                result = result + line + "\n";
            }
            System.out.println(result);
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return result;
	}
	
	@RequestMapping("/home/addData")
	@ResponseBody
	public String addData() {
		
		
		
		return "Inserted All Data";
	}
	
}
