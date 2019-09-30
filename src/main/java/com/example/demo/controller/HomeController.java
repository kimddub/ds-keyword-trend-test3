package com.example.demo.controller;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.groovy.util.Maps;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.demo.service.KeywordService;

@Controller
public class HomeController {
	@Autowired
	KeywordService kService;
	@Value("${custom.tm2Url}")
	String tm2Url;
	
	@RequestMapping("/home/main")
	public String showMain() {
		
		return "home/main";
	}
	
	@RequestMapping("/home/chart")
	public String showChart(@RequestParam Map<String,Object> param, Model model) {
		// DB조회 - 차트그리기
		
		// 출력할 데이터들을 담을 리스트
		List<JSONObject> totalData = new ArrayList<>();
		List<JSONObject> dailyDataList = new ArrayList<>();
		List<JSONObject> monthlyDataList = new ArrayList<>();
		
		// DB에서 꺼내온 데이터 맵이 담길 리스트
		totalData = getJsonDataFromDB(kService.getTotalData(),"pie"); 
		dailyDataList = getJsonDataFromDB(kService.getData(),"line");
		monthlyDataList = getJsonDataFromDB(kService.getMonthlyData(),"line");
		
		if (dailyDataList.size() == 0 || monthlyDataList.size() == 0) {
			model.addAttribute("alertMsg", "분석할 데이터 조회 정보가 없습니다.");
			model.addAttribute("redirectUrl", "../home/main");
			
			return "common/redirect";
		}
		
		model.addAttribute("totalData", totalData);
		model.addAttribute("dailyDataList", dailyDataList);		
		model.addAttribute("monthlyDataList", monthlyDataList);
	
		model.addAttribute("condition",param);
		
		return "home/chart";
	}
	
	private List<JSONObject> getJsonDataFromDB(List<Map<String,Object>> dataList, String type) {

		// 출력할 데이터들을 담을 리스트
		List<JSONObject> result = new ArrayList<>();
		
		if (type.equals("pie")) {
			for( Map.Entry<String, Object> entry : dataList.get(0).entrySet() ) {
				JSONObject jsonObject = new JSONObject();
				
	            jsonObject.put("sentiment", entry.getKey());

	            jsonObject.put("count", entry.getValue());
	            
		        result.add(jsonObject);
	        }
			
			return result;
		}
		

		// 맵으로 담긴 데이터들을 JSON 형태로 결과리스트에 옮기기
		for (Map<String,Object> data : dataList) {
			
			JSONObject jsonObject = new JSONObject();
			
	        for( Map.Entry<String, Object> entry : data.entrySet() ) {
	        	
	            String key = entry.getKey();
	            Object value = entry.getValue();
	            jsonObject.put(key, value);
	        }
			
	        result.add(jsonObject);
		}
	
		return result;
	}
	
	@RequestMapping("/home/addData")
	@ResponseBody
	public String addData(@RequestParam Map<String,Object> param) throws ParseException {
		
		kService.resetBeforeData();
		
		String msg = "";
		
		String url = "";
		String dataStr = "";
		
		// period : 2 (월별)
		param.put("period","2");
		
		// url 셋팅
		url = setUrlOfAssociationTransitionBySentiment(param);
		// tm2 API 조회
		dataStr = readURL(url);
		
		if (dataStr == null) {
			return msg;
		}
				
		List<Map<String,Object>> data2 = getJsonUrl(param,dataStr);
		kService.addDataToMonthlyTable(data2);
		
		// period : 0 (일별)
		param.put("period","0");
		
		// 파라미터 수정 유의!!! 클론?
		String start = (String)param.get("startDate");
		String end = (String)param.get("endDate");
		
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
		Date endDate = dateFormat.parse(end);
		Date pointDate = dateFormat.parse(start); 
		
		Calendar cal = Calendar.getInstance();
		
		// 중간 날짜가 마지막 날짜보다 빠르고, 앞의 달일때만 진행 (같은 달은 따로)
		while ( pointDate.compareTo(endDate) < 0 || pointDate.getMonth() < endDate.getMonth() - 1 )  {
			
			param.put("startDate", dateFormat.format(pointDate));
			System.out.println("startDate : " + dateFormat.format(pointDate));//

			cal.setTime(pointDate);
			cal.add(Calendar.MONTH, 1);
			cal.add(Calendar.DATE, -1);
			pointDate = cal.getTime();
			
			param.put("endDate", dateFormat.format(pointDate));

			System.out.println("endDate : " + dateFormat.format(pointDate));//
			
			// url 셋팅
			url = setUrlOfAssociationTransitionBySentiment(param);
			// tm2 API 조회
			dataStr = readURL(url);
			
			System.out.println(url);
			
			if (dataStr == null) {
				return msg;
			}
			
			List<Map<String,Object>> data = getJsonUrl(param,dataStr);
			kService.addData(data);
			
			cal.add(Calendar.DATE, 1);
			pointDate = cal.getTime();
			
		}
		
		if (pointDate.compareTo(endDate) < 1) {
			param.put("startDate", dateFormat.format(pointDate));
			param.put("endDate", dateFormat.format(endDate));
			
			// url 셋팅
			url = setUrlOfAssociationTransitionBySentiment(param);
			// tm2 API 조회
			dataStr = readURL(url);
			
			List<Map<String,Object>> data = getJsonUrl(param,dataStr);
			kService.addData(data);
		}

		msg = "데이터 조회를 완료했습니다.";
		
		return msg;
	}
	
	@RequestMapping("/home/getJsonUrl")
	private List<Map<String,Object>> getJsonUrl(@RequestParam Map<String,Object> param, String dataStr) {
		
		List<Map<String,Object>> JsonData = new ArrayList<>();
		
		String sourceType = ((String)param.get("source")).trim().substring(0,1).toUpperCase();
		
		try{
			
			// Json parser를 만들어 만들어진 문자열 데이터를 객체화 합니다. 
			JSONParser parser = new JSONParser(); 
			JSONObject obj = (JSONObject) parser.parse(dataStr); 
			
			// Top레벨 단계인 rows 키를 가지고 데이터를 파싱합니다. 
			//JSONObject parse_rows = (JSONObject) obj.get("rows"); 
			
			// List인 rows의 요소를 받아오기 : 뒤에 [ 로 시작하므로 jsonarray이다 
			JSONArray rows = (JSONArray) obj.get("rows"); 
			
			JSONObject row; 
			JSONObject keywordSentiment;
			String date; 
			String source = sourceType;
			Long positive;
			Long negative;
			Long neutral;
			
			// parse_item은 배열형태이기 때문에 하나씩 데이터를 하나씩 가져올때 사용합니다. 
			// 필요한 데이터만 가져오려고합니다. 
			for(int i = 0 ; i < rows.size(); i++) { 
				row = (JSONObject) rows.get(i); 
				
				date = (String)row.get("date");
				
				keywordSentiment = (JSONObject) row.get((String)param.get("keyword")); 
				positive = (Long)keywordSentiment.get("positive");
				negative = (Long)keywordSentiment.get("negative");
				neutral = (Long)keywordSentiment.get("neutral");
				
				JsonData.add(Maps.of("date",date,"source",source,"positive",positive, "negative",negative, "neutral", neutral));
				
			} 
			
		}catch(Exception e){ 
			System.out.println(e.getMessage()); 
		}
		
		return JsonData;
	}
	
	private String readURL(String kewordUrl) {
		
		BufferedReader br = null;
		String DataStr = "";
        String DataLine = "";
		
        try{            
        	// Web to Web
            URL url = new URL(kewordUrl);
            HttpURLConnection urlconnection = (HttpURLConnection) url.openConnection();
            urlconnection.setRequestMethod("GET");
            br = new BufferedReader(new InputStreamReader(urlconnection.getInputStream(),"UTF-8"));
            
            if ((DataLine = br.readLine()) == null) {
            	return null;
            }
            
            while(DataLine != null) {
            	DataStr = DataStr + DataLine + "\n";
            	DataLine = br.readLine();
            }
            
            br.close();
            
        }catch(Exception e){
            System.out.println(e.getMessage());
        }
        
        return DataStr;
	}
	
	private String setUrlOfAssociationTransitionBySentiment(@RequestParam Map<String, Object> param) {

		// period >> 0 : 일별, 1 : 주별,2 : 월별, 3 : 분기,4 : 반기, 5 : 연간
		 
		String urlKeyword = "&keyword=" + URLEncoder.encode((String)param.get("keyword"));
		String urlBasicTm2Condition = "lang=ko&command=GetAssociationTransitionBySentiment";
		String urlSource = "&source=" + param.get("source"); // insta, blog, twitter, news ...
		String urlStartDate = "&startDate=" + param.get("startDate");
		String urlEndDate = "&endDate=" + param.get("endDate");
		String urlPeriod = "&period=" + param.get("period");
		
		String keywordUrl = tm2Url + urlBasicTm2Condition
									+ urlKeyword
									+ urlSource
									+ urlStartDate
									+ urlEndDate
									+ urlPeriod;
		
		return keywordUrl;
	}
	
	
}
