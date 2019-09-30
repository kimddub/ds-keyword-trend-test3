<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>연관감성어 분석 결과</title>

<link rel="stylesheet" href="/css/app/app.css">
<style>
	#chartdiv-total {
	  width: 100%;
	  height: 500px;
	}
	
	#chartdiv-monthly {
	  width: 100%;
	  height: 500px;
	}
	
	#chartdiv-daily {
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

	//////////////
	// 평균차트 //
	//////////////
am4core.ready(function() {

	// Themes begin
	am4core.useTheme(am4themes_animated);
	// Themes end

	// Create chart instance
	var chart = am4core.create("chartdiv-total", am4charts.PieChart);

	// Add and configure Series
	var pieSeries = chart.series.push(new am4charts.PieSeries());
	pieSeries.dataFields.value = "count";
	pieSeries.dataFields.category = "sentiment";

	// Let's cut a hole in our Pie chart the size of 30% the radius
	chart.innerRadius = am4core.percent(30);

	// Put a thick white border around each Slice
	pieSeries.slices.template.stroke = am4core.color("#fff");
	pieSeries.slices.template.strokeWidth = 2;
	pieSeries.slices.template.strokeOpacity = 1;
	pieSeries.slices.template
	
	  // change the cursor on hover to make it apparent the object can be interacted with
	  .cursorOverStyle = [
	    {
	      "property": "cursor",
	      "value": "pointer"
	    }
	  ];

	pieSeries.alignLabels = false;
	pieSeries.labels.template.bent = false;
	pieSeries.labels.template.radius = -40;
	pieSeries.labels.template.fill = am4core.color("#fff");
	pieSeries.labels.template.padding(0, 0, 0, 0);

	pieSeries.ticks.template.disabled = true;

	// Create a base filter effect (as if it's not there) for the hover to return to
	var shadow = pieSeries.slices.template.filters.push(new am4core.DropShadowFilter);
	shadow.opacity = 0;

	// Create hover state
	var hoverState = pieSeries.slices.template.states.getKey("hover"); // normally we have to create the hover state, in this case it already exists

	// Slightly shift the shadow and make it more prominent on hover
	var hoverShadow = hoverState.filters.push(new am4core.DropShadowFilter);
	hoverShadow.opacity = 0.7;
	hoverShadow.blur = 5;

	// Add a legend
	chart.legend = new am4charts.Legend();

	chart.data = ${totalData};

	}); // end am4core.ready()

	//////////////
	// 일별차트 //
	//////////////
am4core.ready(function() {
	
	// Themes begin
	am4core.useTheme(am4themes_animated);
	// Themes end
	
	// Create chart instance
	var chart = am4core.create("chartdiv-daily", am4charts.XYChart);
	
	// Add data
	chart.data = ${dailyDataList}
	
	// Create category axis
	var categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
	categoryAxis.dataFields.category = "date";
	categoryAxis.renderer.opposite = false;
	
	// Create value axis
	var valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
	valueAxis.renderer.inversed = false;
	valueAxis.renderer.minLabelPosition = 0.01;
	
	// Create series
	var series1 = chart.series.push(new am4charts.LineSeries());
	series1.dataFields.valueY = "positive";
	series1.dataFields.categoryX = "date";
	series1.name = "긍정";
	series1.strokeWidth = 1.5;
	//series1.bullets.push(new am4charts.CircleBullet());
	series1.tooltipText = "{name} : {valueY} ({categoryX})";
	series1.legendSettings.valueText = "{valueY}";
	series1.visible  = false;
	
	var series2 = chart.series.push(new am4charts.LineSeries());
	series2.dataFields.valueY = "negative";
	series2.dataFields.categoryX = "date";
	series2.name = '부정';
	series2.strokeWidth = 1.5;
	//series2.bullets.push(new am4charts.CircleBullet());
	series2.tooltipText = "{name} : {valueY} ({categoryX})";
	series2.legendSettings.valueText = "{valueY}";
	
	var series3 = chart.series.push(new am4charts.LineSeries());
	series3.dataFields.valueY = "neutral";
	series3.dataFields.categoryX = "date";
	series3.name = '중립';
	series3.strokeWidth = 1.5;
	//series3.bullets.push(new am4charts.CircleBullet());
	series3.tooltipText = "{name} : {valueY} ({categoryX})";
	series3.legendSettings.valueText = "{valueY}";
	
	// Add chart cursor
	chart.cursor = new am4charts.XYCursor();
	chart.cursor.behavior = "zoomY";
	
	// Add legend
	chart.legend = new am4charts.Legend();

}); // end am4core.ready()

	//////////////
	// 월별차트 //
	//////////////
	am4core.ready(function() {
	
	// Themes begin
	am4core.useTheme(am4themes_animated);
	// Themes end
	
	// Create chart instance
	var chart = am4core.create("chartdiv-monthly", am4charts.XYChart);
	
	// Add data
	chart.data = ${monthlyDataList};
	
	// Create axes
	var categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
	categoryAxis.dataFields.category = "date";
	categoryAxis.renderer.grid.template.location = 0;
	
	
	var valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
	valueAxis.renderer.inside = true;
	valueAxis.renderer.labels.template.disabled = true;
	valueAxis.min = 0;
	
	// Create series
	function createSeries(field, name) {
	  
	  // Set up series
	  var series = chart.series.push(new am4charts.ColumnSeries());
	  series.name = name;
	  series.dataFields.valueY = field;
	  series.dataFields.categoryX = "date";
	  series.sequencedInterpolation = true;
	  
	  // Make it stacked
	  series.stacked = true;
	  
	  // Configure columns
	  series.columns.template.width = am4core.percent(60);
	  series.columns.template.tooltipText = "[bold]{name}[/]\n[font-size:14px]{categoryX}: {valueY}";
	  
	  // Add label
	  var labelBullet = series.bullets.push(new am4charts.LabelBullet());
	  labelBullet.label.text = "{valueY}";
	  labelBullet.locationY = 0.5;
	  
	  return series;
	}
	
	createSeries("positive", "긍정");
	createSeries("negative", "부정");
	createSeries("neutral", "중립");
	
	// Legend
	chart.legend = new am4charts.Legend();
	
}); // end am4core.ready()
</script>

</head>
<body>

	<header class="con">
		<h1>연관어 감성 분석 결과</h1>
	</header>
	
	<section class="con keyword-info">
		<span class="keyword">${condition.keyword}</span><br/>
		
		<div class="keyword-source">
			소셜미디어: 
			<select name="source">
				<option value="insta">인스타그램</option>
			</select>
		</div>
	</section>
	
	<div class="con chart-box">
		<div class="chart-info">
			<span> ${condition.keyword} 긍/부정 평균 그래프 (기간 : ${condition.startDate} ~ ${condition.endDate})</span>
		</div>

		<div id="chartdiv-total"></div>
	</div>

	<div class="con chart-box">
		<div class="chart-info">
			<span> ${condition.keyword} 긍/부정 추이 월별 그래프 (기간 : ${condition.startDate} ~ ${condition.endDate})</span>
		</div>

		<div id="chartdiv-monthly"></div>
	</div>
	
	<div class="con chart-box">
		<div class="chart-info">
			<span> ${condition.keyword} 긍/부정 추이 일별 그래프 (기간 : ${condition.startDate} ~ ${condition.endDate})</span>
		</div>
		
		<div id="chartdiv-daily"></div>
	</div>

</body>
</html>