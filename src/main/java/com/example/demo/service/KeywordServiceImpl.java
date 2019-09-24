package com.example.demo.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.dao.KeywordDao;

@Service
public class KeywordServiceImpl implements KeywordService {
	@Autowired
	KeywordDao kDao;
	
	public void addData(List<Map<String, Object>> data) {
		kDao.insert(data);
	}
}
