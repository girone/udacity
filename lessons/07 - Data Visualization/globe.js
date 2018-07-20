
function populate_years(start, end, step) {

    var years = []; //empty years array

    for (var y = start; y <= end; y += step) {
        if (y < 1942 || y > 1946) {
            years.push(y);
        }
    }

    return years;  //return years array
};

var years = populate_years(1930, 2015, 4);

function draw(geo_data) {
    "use strict";
    var margin = 150,
        width = 1920 - margin,
        height = 1080 - margin;

    var svg = d3.select("body")
        .append("svg")
        .attr("width", width + margin)
        .attr("height", height + margin)
        .append("g")
        .attr("class", "map");

    var projection = d3.geo.mercator()
        .scale(150)
        .translate([width / 2, height / 2]);

    var path = d3.geo.path().projection(projection);

    var map = svg.selectAll("path")
        .data(geo_data.features)
        .enter()
        .append("path")
        .attr("d", path)
        .style("fill", "rgb(9, 157, 217)")
        .style("stroke", "black")
        .style("stroke-width", 0.5);

    function aggregate_year(leaves) {
        var total = d3.sum(leaves, function (d) {
            return d["attendance"];
        });

        var coords = leaves.map(function (d) {
            return projection([+d.long, +d.lat]);
        });

        var center_x = d3.mean(coords, function (d) {
            return d[0];
        });

        var center_y = d3.mean(coords, function (d) {
            return d[1];
        });

        var teams = d3.set();
        leaves.forEach(function (d) {
            teams.add(d["team1"]);
            teams.add(d["team2"]);
        });

        return {
            "attendance": total,
            "x": center_x,
            "y": center_y,
            "teams": teams.values(),
        };
    };

    function plot_points(data) {
        // draw circles logic
        var nested = d3.nest()
            .key(function (d) {
                return d["date"].getUTCFullYear();
            })
            .rollup(aggregate_year)
            .entries(data);

        var attendance_max = d3.max(nested, function (d) {
            return d.values["attendance"];
        });

        var radius = d3.scale.sqrt()
            .domain([0, attendance_max])
            .range([0, 13]);  // last value is hand-tuned

        function key_func(d) {
            return d["key"];
        };

        svg.append("g")
            .attr("class", "bubble")
            .selectAll("circle")
            .data(nested.sort(function (a, b) {
                // Sorting avoids plotting smaller circles below larger circles.
                return b.values["attendance"] - a.values["attendance"];
            }), key_func)
            .enter()
            .append("circle")
            .attr("cx", function (d) { return d.values["x"]; })
            .attr("cy", function (d) { return d.values["y"]; })
            .attr("r", function (d) { return radius(d.values["attendance"]); });

        function update(year) {
            var filtered = nested.filter(function (d) {
                return new Date(d["key"]).getUTCFullYear() === year;
            });

            d3.select("h2")
                .text("World Cup " + year);

            // Show only the hosting country.
            var circles = svg.selectAll("circle")
                .data(filtered, key_func);

            circles.exit().remove()
                .transition()
                .duration(500);

            circles.enter()
                .append("circle")
                .transition()
                .duration(500)
                .attr("cx", function(d) {return d.values["x"]; })
                .attr("cy", function(d) {return d.values["y"]; })
                .attr("r", function(d) {return radius(d.values["attendance"]); });

            // Highlight participating teams.
            var countries = filtered[0].values["teams"];

            function update_countries(d) {
                    if (countries.indexOf(d.properties.name) != -1) {
                        return "lightBlue";
                    } else {
                        return "white";
                    }
            };

            svg.selectAll("path")
                .transition()
                .duration(500)
                .style("fill", update_countries)
                .style("stroke", update_countries);
        };

        /**
         * Makes the visualization interactive.
         */
        function showButtons() {
            var buttons = d3.select("body")
                .append("div")
                .attr("class", "years_buttons")
                .selectAll("div")
                .data(years)
                .enter()
                .append("div")
                .text(function(d) { return d; });

            buttons.on("click", function(d) {
                d3.select(".years_buttons")
                    .selectAll("div")
                    .transition()
                    .duration(500)
                    .style("color", "black")
                    .style("background", "rgb(251, 201, 127)")
                d3.select(this)
                    .transition()
                    .duration(500)
                    .style("background", "lightBlue")
                    .style("color", "white");
                update(d);
            })
        }

        var year_idx = 0;

        // Animation using setInterval.
        var year_interval = setInterval(function() {
            update(years[year_idx]);

            year_idx++;

            if (year_idx >= years.length) {
                clearInterval(year_interval);
                // Make the visualization interactive once the author-driven part is done.
                showButtons();
            }
        }, 1000);
    };

    var format = d3.time.format("%d-%m-%Y (%H:%M h)");

    d3.tsv("world_cup_geo.tsv", function (d) {
        d["attendance"] = +d["attendance"];
        d["date"] = format.parse(d["date"]);
        return d;
    }, plot_points);
};
