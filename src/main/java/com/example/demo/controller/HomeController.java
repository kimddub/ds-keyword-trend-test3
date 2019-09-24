package com.example.demo.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.groovy.util.Maps;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.service.KeywordService;

@Controller
public class HomeController {
	@Autowired
	KeywordService kService;
	
	String urlStr1 = "http://qt.some.co.kr/TrendMap/JSON/ServiceHandler?lang=ko&source=blog&startDate=20190901&endDate=20190924";
	String keyword = "나이키";
	String urlKeyword = "&keyword=" + "%EB%82%98%EC%9D%B4%ED%82%A4";
	String urlStr2 = "&topN=100&cutOffFrequencyMin=0&cutOffFrequencyMax=0&period=0&invertRowCol=on&start_weekday=SUNDAY&categorySetName=SM&command=GetAssociationTransitionBySentiment";
	String urlStr = urlStr1 + urlKeyword + urlStr2;
	
	@RequestMapping("/home")
	public String showMain(HttpServletRequest rq, HttpServletResponse rs) {
		
		return "home/main";
	}
	
	@RequestMapping("/home/getJsonData")
	@ResponseBody
	public List<Map<String,Object>> getJsonData() {
		List<Map<String,Object>> resultArr = new ArrayList<>();
		String result = "[";

		String strData = readURL(urlStr);
		
		try{
			
			// Json parser를 만들어 만들어진 문자열 데이터를 객체화 합니다. 
			JSONParser parser = new JSONParser(); 
			JSONObject obj = (JSONObject) parser.parse(strData); 
			
			// Top레벨 단계인 rows 키를 가지고 데이터를 파싱합니다. 
			//JSONObject parse_rows = (JSONObject) obj.get("rows"); 
			
			// List인 rows의 요소를 받아오기 : 뒤에 [ 로 시작하므로 jsonarray이다 
			JSONArray rows = (JSONArray) obj.get("rows"); 
			
			JSONObject row; 
			JSONObject keywordSentiment;
			String date; 
			Long positive;
			Long negative;
			Long neutral;
			
			// parse_item은 배열형태이기 때문에 하나씩 데이터를 하나씩 가져올때 사용합니다. 
			// 필요한 데이터만 가져오려고합니다. 
			for(int i = 0 ; i < rows.size(); i++) { 
				row = (JSONObject) rows.get(i); 
				
				date = (String)row.get("date");
				
				keywordSentiment = (JSONObject) row.get(keyword); 
				positive = (Long)keywordSentiment.get("positive");
				negative = (Long)keywordSentiment.get("negative");
				neutral = (Long)keywordSentiment.get("neutral");
				
				resultArr.add(Maps.of("date",date,"positive",positive, "negative",negative, "neutral", neutral));
				
				result += "{ date : "+ date; 
				result += ", positive : "+ positive; 
				result += ", negative : "+ negative; 
				result += ", neutral : "+ neutral; 
				result += " }\n"; 
			} 
			
			result += "]";
			
			// 마지막에보면 에러가 발생하였는데 casting문제입니다. 
			// 이는 반환되는 데이터타입이 달라서
			
		}catch(Exception e){ 
			System.out.println(e.getMessage()); 
		}
		
		return resultArr;
	}
	
	@RequestMapping("/home/getData")
	@ResponseBody
	public String readURL(String urlStr) {
		String result = "";
		
		BufferedReader br = null;
        String line = "";
		
        try{            
            URL url = new URL(urlStr);
            HttpURLConnection urlconnection = (HttpURLConnection) url.openConnection();
            urlconnection.setRequestMethod("GET");
            br = new BufferedReader(new InputStreamReader(urlconnection.getInputStream(),"UTF-8"));
            
            int cnt = 0;
            
            while((line = br.readLine()) != null) {
            	if ( cnt == 1) {
                	break;
                }
            	
            	cnt++;
                result = result + line + "\n";
            }
            
            br.close();
            
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return result;
	}
	
	@RequestMapping("/home/addData")
	@ResponseBody
	public String addData() {
		
		List<Map<String,Object>> data = getJsonData();
		
		kService.addData(data);
		
		return "Inserted All Data";
	}
	
}
