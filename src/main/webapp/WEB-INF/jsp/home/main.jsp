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

		$.post( 
			"home/getData", 
			function( data ) {

				if (confirm("데이터 조회 결과를 가져오시겠습니까?") == false) {
					return false;
				}
				
				var $dataBox = $( ".data-box" );
				$dataBox.append("<textarea class='data' name='data' readonly></textarea>");
				$dataBox.append("<button class='data-inserting' onclick='location.href='./addData'';>데이터 삽입</button>");
				
				var $data = $( ".data-box textarea[name='data']" );
				$data.append(data);
			},
			"html");
	}
	
</script>

</head>
<body>

<h1>${param.key}</h1>

<button class="data-btn" onclick="getData();">연관어 조회</button>
 
<div class="data-box">
</div>

</body>
</html>