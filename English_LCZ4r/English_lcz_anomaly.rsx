##LCZ4r Local Functions=group
##Calculate LCZ Anomaly=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None
##QgsProcessingParameterFeatureSource|INPUT|Input data|5
##QgsProcessingParameterField|variable|Target variable column|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Column identifying stations|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Start date|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|End date|DD-MM-YYYY|False
##QgsProcessingParameterEnum|Time_frequency|Time Frequency|hour;day;DSTday;week;month;season;quater;year|-1|0|False
##QgsProcessingParameterString|Select_hour|Specific a hour|0:23|optional|True
##QgsProcessingParameterEnum|Select_extract_type|Select the extract method to use|simple;two.step;bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Split data by|year;season;seasonyear;month;monthyear;weekday;weekend;dst;hour;daylight;daylight-month;daylight-season;daylight-year|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Impute missing values|mean;median;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|Select plot type|diverging_bar;bar;dot;lollipop|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Choose palette color|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Egypt;Greek;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronese|-1|0|False
##QgsProcessingParameterString|Title|Title|LCZ anomalies|optional|true
##QgsProcessingParameterString|xlab|xlab|Stations|optional|true
##QgsProcessingParameterString|ylab|ylab|Air Temperature [ºC]|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Legend name|Anomaly [ºC]|optional|true
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|display|Visualize plot(.html)|True
##QgsProcessingParameterBoolean|Save_as_plot|Save as plot|True
##QgsProcessingParameterFileDestination|Output|Save your image|PNG Files (*.png)

library(LCZ4r)
library(sf)
library(ggplot2)
library(terra)
library(lubridate)
library(ggiraph)
library(htmlwidgets)

#Check extract method type
time_options <- c("hour", "day", "DSTday", "week", "month", "season", "quater", "year")
if (!is.null(Time_frequency) && Time_frequency >= 0 && Time_frequency < length(time_options)) {
  result_time <- time_options[Time_frequency + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_time <- NULL  
}

#Check extract method type
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
}


#Check plot type
plots <- c("diverging_bar", "bar", "dot", "lollipop")
if (!is.null(Select_plot_type) && Select_plot_type >= 0 && Select_plot_type < length(plots)) {
  result_plot <- plots[Select_plot_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_plot <- NULL  # Handle invalid or missing selection
}

#Check color type
colors <- c("VanGogh2", "Archambault", "Cassatt1", "Cassatt2", "Demuth", "Derain", "Egypt", "Greek", "Hiroshige", "Hokusai2", "Hokusai3", "Ingres", "Isfahan1", "Isfahan2", "Java", "Johnson", "Kandinsky", "Morgenstern", "OKeeffe2", "Pillement", "Tam", "Troy", "VanGogh3", "Veronese")
if (!is.null(Palette_color) && Palette_color >= 0 && Palette_color < length(colors)) {
  result_colors <- colors[Palette_color + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_colors <- NULL  # Handle invalid or missing selection
}
#Check impute missing values
imputes <- c("mean", "median", "knn", "bag")
if (!is.null(Impute_missing_values) && Impute_missing_values >= 0 && Impute_missing_values < length(imputes)) {
  result_imputes <- imputes[Impute_missing_values + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_imputes <- NULL  # Handle invalid or missing selection
}

# Check for date conditions by
type_by <- c("year","season", "seasonyear", "month", "monthyear","weekday", "weekend", "dst", "hour", "daylight", "daylight-month", "daylight-season", "daylight-year")
if (!is.null(Split_data_by) && Split_data_by >= 0 && Split_data_by < length(type_by)) {
  result_by <- type_by[Split_data_by + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_by <- NULL  # Handle invalid or missing selection
}

if ("daylight-month" %in% result_by) {
    result_by <- c("daylight", "month")
}
if ("daylight-season" %in% result_by) {
    result_by <- c("daylight", "season")
}
if ("daylight-year" %in% result_by) {
    result_by <- c("daylight", "year")
}


# Generate and plot or data.frame ----
INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

# Check if Hour is an empty string and handle accordingly
if(Select_hour != "") { 

    if (grepl(":", Select_hour)) { 
  # Directly convert to numeric range
    Select_hour <- as.numeric(unlist(strsplit(Select_hour, ":")))  # Split and convert to numeric
    Select_hour <- Select_hour[1]:Select_hour[2]  # Create a range from start to end hour
    } else if (grepl(",", Select_hour)) {
    Select_hour <- as.numeric(unlist(strsplit(gsub("c\\(|\\)", "", Select_hour), ",")))
    } else {
    Select_hour <- as.numeric(Select_hour)  # Convert to numeric if not a range
    }
    if (Save_as_plot==TRUE) {
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          time.freq = result_time, 
                          extract.method = result_extract,
                          by = result_by,
                          plot_type=result_plot,
                          impute= result_imputes,
                          legend_name=Legend_name,
                          palette = result_colors,
                          iplot = TRUE, title = Title, caption = Caption, xlab = xlab, ylab = ylab)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
    width_svg = 16,
    height_svg = 9,
    options = list(
    opts_sizing(rescale = TRUE, width = 1),
    opts_tooltip(css = "background-color:white; color:black; font-size:120%; padding:10px;"),
    opts_hover_inv(css = "opacity:0.5;"),
    opts_hover(css = "cursor:pointer; opacity: 0.8;"),
    opts_zoom(min = 0.5, max = 2)
  )
) %>%
  htmlwidgets::saveWidget(
  file = html_file,
  selfcontained = FALSE, # Ensures all dependencies are embedded
  libdir = NULL, # Keep dependencies inline
  title = "LCZ4r Visualization"
)

    # Add caption
    cat('<p style="text-align:right; font-size:16px;">',
    'LCZ4r Project: <a href="https://bymaxanjos.github.io/LCZ4r/index.html" target="_blank">by Max Anjos</a>',
    '</p>', sep = "\n", file = html_file, append = TRUE)

    # Open the HTML file in the default web browser
    utils::browseURL(html_file)
    }
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end, hour=Select_hour,
                         time.freq = result_time,
                         extract.method = result_extract,
                         by = result_by,
                         impute = Impute_missing_values, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
} else {
    if (Save_as_plot==TRUE){
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          time.freq = result_time, 
                          extract.method = result_extract,
                          by = result_by,
                          plot_type=result_plot,
                          impute= result_imputes,
                          legend_name=Legend_name,
                          palette = result_colors,
                          iplot = TRUE, title = Title, caption = Caption, xlab = xlab, ylab = ylab)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
    width_svg = 16,
    height_svg = 9,
    options = list(
    opts_sizing(rescale = TRUE, width = 1),
    opts_tooltip(css = "background-color:white; color:black; font-size:120%; padding:10px;"),
    opts_hover_inv(css = "opacity:0.5;"),
    opts_hover(css = "cursor:pointer; opacity: 0.8;"),
    opts_zoom(min = 0.5, max = 2)
  )
) %>%
  htmlwidgets::saveWidget(
  file = html_file,
  selfcontained = FALSE, # Ensures all dependencies are embedded
  libdir = NULL, # Keep dependencies inline
  title = "LCZ4r Visualization"
)

    # Add caption
    cat('<p style="text-align:right; font-size:16px;">',
    'LCZ4r Project: <a href="https://bymaxanjos.github.io/LCZ4r/index.html" target="_blank">by Max Anjos</a>',
    '</p>', sep = "\n", file = html_file, append = TRUE)

    # Open the HTML file in the default web browser
    utils::browseURL(html_file)
    }
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = result_time,
                         extract.method = result_extract,
                         by = result_by,
                         impute = result_imputes, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
}
 

#' LCZ_map: A <b>SpatRaster</b> object derived from the <em>Download LCZ map* functions.</em>
#' INPUT: A data frame (.csv) containing environmental variable data structured as follows:</p><p>
#'      :1. <b>date</b>: A column with date-time information. Ensure the column is named <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>:  A column specifying meteorological station identifiers;</p><p>
#'      :3. <b>Variable</b>: A column representing the environmental variable (e.g., air temperature, relative humidity);</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns providing the geographical coordinates of data points. Ensure the column is named <code style='background-color: lightblue;'>lat|latitude and lon|long|longitude</code>.</p><p>
#'      :Formatting Note: Users must standardize the date-time format to R conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format i.e. “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more information, see the: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>sample data.</a> 
#' variable: The name of the target variable column in the data frame (e.g., airT, RH).
#' station_id: The column in the data frame identifying meteorological stations (e.g., station, site, id).
#' Date_start: Specify the start dates for the analysis. The format should be <b>DD-MM-YYYY [01-09-1986]</b>.
#' Date_end: The end date, formatted similarly to start date.
#' Time_frequency: Defines the time resolution for averageing. Default is “hour”. Supported resolutions include: “hour”, “day”, “DSTday”, “week”, “month”, “quarter” or “year”.
#' Select_extract_type: character string specifying the method used to assign the LCZ class to each station point. The default is "simple". Available methods are:</p><p>
#'      :1. <b>simple</b>: Assigns the LCZ class based on the value of the raster cell in which the point falls. It often is used in low-density observational network. </p><p>
#'      :2. <b>two.step</b>: Assigns LCZs to stations while filtering out those located in heterogeneous LCZ areas. This method requires that at least 80% of the pixels within a 5 × 5 kernel match the LCZ of the center pixel (Daniel et al., 2017). Note that this method reduces the number of stations. It often is used in ultra and high-density observational network, especially in LCZ classes with multiple stations.</p><p>
#'      :3. <b>bilinear</b>:  Interpolates the LCZ class values from the four nearest raster cells surrounding the point. </p><p>
#' Split_data_by:Determines how the time series is segmented. Options include: year, month, daylight, dst, wd (wind direction) and so on. For example, daylight split up data into daytime and nighttime periods.</p><p> 
#'              :You can also use the following combination: daylight-month, daylight-season or daylight-year (make sure at least Time_resolution as “hour”).</p><p>
#'              :For more details, visit: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type in openair R package.</a>.
#' Select_hour:Specify an hour or a range of hours to select from 0 to 23. You can use the following formats:</p><p>
#'      :A range: 0:12 selects hours 0 to 12 inclusive;</p><p>
#'      :A specific set: c(1, 6, 18, 21) to selects hours 1, 6, 18, and 21;</p><p>
#'      :If the data is on a daily, monthly, or yearly basis, leave this parameter empty.
#' Select_plot_type: Choose from:</p><p>
#'      :1. <b>diverging_bar</b>: A horizontal bar plot that diverges from the center (zero), with positive anomalies extending to the right and negative anomalies to the left. This plot is good for showing the extent and direction of anomalies in a compact format;</p><p>
#'      :2. <b>bar</b>:A bar plot showing the magnitude of the anomaly for each station, colored by whether the anomaly is positive or negative. This plot is good for comparing anomalies across stations;</p><p>
#'      :3. <b>dot</b>: A dot plot that displays both the mean temperature values and the reference values, with lines connecting them. The size or color of the dots can indicate the magnitude of the anomaly. Ideal for showing both absolute temperature values and their anomalies;</p><p>
#'      :4. <b>lollipop</b>: A lollipop plot where each "stick" represents an anomaly value and the dots at the top represent the size of the anomaly. Useful for clearly showing positive and negative anomalies in a minimalist way.</p><p>
#' Impute_missing_values:Method to impute missing values in data: “mean”, “median”, “knn”, “bag”.
#' display: If TRUE, the plot will be displayed in your web browser as an HTML visualization.
#' Save_as_plot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs (e.g., .jpeg for plot and .csv for table). 
#' Palette_color: Define the color palette for plots. Explore additional palettes from the <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>MetBrewer R package.</a>
#' Output:1. If Save as plot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TTIF (.tif), PDF (*.pdf), SVG (*.svg) Example: <b>/Users/myPC/Documents/name_lcz_anomaly.png</b>;</p><p>
#'       :2. if Save as plot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/name_lcz_anomaly.csv</b>
#' ALG_DESC:This function caluculates thermal anomaly for different LCZs.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_anomaly.html'>LCZ Local Functions(Thermal Anomalies).</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0