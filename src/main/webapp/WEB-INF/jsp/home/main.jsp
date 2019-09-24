<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>main</title>

<!-- <script src="/js/plugins/chart/amcharts.js"></script>  -->
<!-- <script src="/js/plugins/chart/pie.js"></script>  -->
<!-- <script src="/js/plugins/chart/serial.js"></script>  -->
<!-- <script src="/js/plugins/chart/light.js"></script> -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>

<style>

	.data-box > .data {
		margin:0 auto;
		width:80%;
		min-height:500px;
	}

</style>

<script>

	function getData() {

		if (confirm("데이터 조회 결과를 가져오시겠습니까?") == false) {
			return false;
		}

		alert("현재 이용할 수 없는 서비스입니다."); //Json타입 데이터 ajax하도록 해야함
		return false;

		$.post( 
			"./getJsonData", 
			function( data ) {
				
				var $dataBox = $( ".data-box" );
				$dataBox.empty();
				$dataBox.append("<textarea class='data' name='data' readonly></textarea>");
				$dataBox.append("<button class='data-inserting' onclick='location.href='./addData'';>데이터 삽입</button>");
				
				var $data = $( ".data-box textarea[name='data']" );
				$data.append(data);
			},
			"html");
	}

	function addData() {

		if (confirm("데이터 결과를 데이터베이스에 입력하시겠습니까?") == false) {
			return false;
		}

		$.post( 
			"./addData", 
			function( data ) {
				alert("데이터를 입력했습니다.");
			},
			"html");
	}
</script>

</head>
<body>

<h1>${param.key}</h1>

<button class="data-btn" onclick="getData();">'나이키' tm2 분석</button>

<button class="data-btn" onclick="addData();">'나이키' tm2 to DB</button>
 
<div class="data-box">
</div>

</body>
</html>