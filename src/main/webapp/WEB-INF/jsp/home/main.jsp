<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>연관감성어 분석</title>

<link rel="stylesheet" href="/css/app/app.css">
<style>
	#chartdiv {
	  width: 100%;
	  height: 500px;
	}

	.data-box > .data {
		margin:50px auto;
		width:50%;
		min-height:300px;
	}

</style>

<!-- Resources -->
<script src="https://www.amcharts.com/lib/4/core.js"></script>
<script src="https://www.amcharts.com/lib/4/charts.js"></script>
<script src="https://www.amcharts.com/lib/4/themes/animated.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script>

	var $dataList = []; 	

	var keyword = "";
	var startDate = "";
	var endDate = "";
	var period = "";
	var source = "";

	function formCheck() {
		//입력유무
		//최대길이 (db관련?)
		//한글영어숫자 등?
	}

	function addData() {

		if (confirm("연관어를 조회하시겠습니까?") == false) {
			return false;
		}
		
		// period >> 0 : 일별, 1 : 주별,2 : 월별, 3 : 분기,4 : 반기, 5 : 연간
		
		keyword = $('input[name="keyword"]').val().trim(); 
		startDate = $('input[name="startDate"]').val().trim(); 
		endDate = $('input[name="endDate"]').val().trim(); 
		source = $('select[name="source"]').val().trim(); 
		period = $('select[name="period"]').val().trim(); 

		
		$.post( 
			"/home/addData",  
			{
				"keyword" : keyword,
				"startDate" : startDate,
				"endDate" : endDate,
				"source" : source,
				"period" : period
			},
			function( msg ) {

				if (msg == "" || msg.length == 0) {
					alert("조회할 데이터가 없습니다.");
					return false;
				} 

				alert(msg);
				
				var $msgBox = $('.data-analysis-complete-msg');
				$msgBox.empty();
				$msgBox.append("'" + keyword + "' 분석 차트를 확인해보세요!");

				$('.data-btn.disable-btn').removeClass('disable-btn');
				
// 				var $dataBox = $( ".data-box" );
// 				$dataBox.empty();
// 				$dataBox.append("<textarea class='data' name='data' readonly></textarea>");
				
// 				var $data = $( ".data-box textarea[name='data']" );
// 				$data.append(dataStr);
			},
			"html");
	}

	function openInNewTab(url) {
	  var win = window.open(url, '_blank');
	  win.focus();
	}
</script>

</head>
<body>

	<header class="con">
		<h1>연관어 감성 분석</h1>
	</header>
	
	<div class="con keyword-form">
		<form action="./chart" method="post" target="_blank">

			<table>
				<tr>
					<th>키워드: </th>
					<td><input type="text" name="keyword" value="나이키" readonly/></td>
				</tr>
				<tr>
					<th>조회기간: </th>
					<td><input type="text" name="startDate" value="20190101" readonly/>
					~ <input type="text" name="endDate" value="20190901" readonly/></td>
				</tr>
				<tr>
					<th>조회단위: </th>
					<td>
						<select name="period">
							<option value="0" >일별</option>
						</select>
					</td>
				</tr>
				<tr>
					<th>소셜미디어: </th>
					<td>
						<select name="source">
							<option value="insta" value="insta" readonly>인스타그램</option>
						</select>
					</td>
				</tr>
			</table>
			
			<span class="data-analysis-complete-msg"></span><br/>
				
			<input type="button" class="data-btn" onclick="addData();" value="조회하기">
			
			<input type="submit" class="data-btn disable-btn" value="분석보기">
		</form>
	</div>		
	
	<div class="con data-box"></div>

</body>
</html>