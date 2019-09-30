<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Test</title>

<!-- Styles -->
<style>
#chartdiv {
  width: 100%;
  height: 500px;
}

</style>

<!-- Resources -->
<script src="https://www.amcharts.com/lib/4/core.js"></script>
<script src="https://www.amcharts.com/lib/4/charts.js"></script>
<script src="https://www.amcharts.com/lib/4/themes/animated.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>

<!-- Chart code -->
<script>
	var $dataList = []; 

	$.post(
		"/home/getDataFromDB",
		function(dataList) {
			
			$dataList = JSON.parse(dataList);
			
			drawChart();
		},
		"html"
	);
	
	function drawChart() {
		am4core.ready(function() {
	
			// Themes begin
			am4core.useTheme(am4themes_animated);
			// Themes end
			
			// Create chart instance
			var chart = am4core.create("chartdiv", am4charts.XYChart);
		
			// Add data
			chart.data = $dataList;
	// 			[{
	// 		  "date": "2016",
	// 		  "positive": 10,
	// 		  "negative": 2.5,
	// 		  "neutral": 2.1,
	// 		}, {
	// 		  "date": "2017",
	// 		  "positive": 2.5,
	// 		  "negative": 2.5,
	// 		  "neutral": 2.1,
	// 		}, {
	// 		  "date": "2018",
	// 		  "positive": 2.5,
	// 		  "negative": 2.5,
	// 		  "neutral": 2.1,
	// 		}];
			
			chart.legend = new am4charts.Legend();
			chart.legend.position = "right";
			
			// Create axes
			var categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
			categoryAxis.dataFields.category = "date";
			categoryAxis.renderer.grid.template.opacity = 1;
			
			var valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
			valueAxis.min = 0;
			valueAxis.renderer.grid.template.opacity = 0;
			valueAxis.renderer.ticks.template.strokeOpacity = 0.5;
			valueAxis.renderer.ticks.template.stroke = am4core.color("#495C43");
			valueAxis.renderer.ticks.template.length = 10;
			valueAxis.renderer.line.strokeOpacity = 0.5;
			valueAxis.renderer.baseGrid.disabled = true;
			valueAxis.renderer.minGridDistance = 40;
			
			// Create series
			function createSeries(field, name) {
			  var series = chart.series.push(new am4charts.ColumnSeries());
			  series.dataFields.valueX = field;
			  series.dataFields.categoryY = "date";
			  series.stacked = true;
			  series.name = name;
			  
			  var labelBullet = series.bullets.push(new am4charts.LabelBullet());
			  labelBullet.locationX = 0.5;
			  labelBullet.label.text = "{valueX}";
			  labelBullet.label.fill = am4core.color("#fff");
			}
			
			createSeries("positive", "긍정");
			createSeries("negative", "부정");
			createSeries("neutral", "중립");
		});// end am4core.ready()
	
	} 
</script>
</head>
<body>

<!-- HTML -->
<div id="chartdiv"></div>

</body>
</html>