function draw(data) {
    var svg = d3.select("body")
        .append("svg")
        .attr("width", 800)
        .attr("height", 600)
        .append("g")
        .attr("class", "chart");
    /**
     * Dimple.js chart construction code.
     */
    var myChart = new dimple.chart(svg, data);
    var x = myChart.addTimeAxis("x", "year");
    x.dateParseFormat = "%Y";
    x.tickFormat = "%Y";
    x.timeInterval = 4;
    myChart.addMeasureAxis("y", "attendance");
    myChart.addSeries(null, dimple.plot.bar);
    myChart.draw();
}

var data = d3.tsv("world_cup_data.tsv", draw);
