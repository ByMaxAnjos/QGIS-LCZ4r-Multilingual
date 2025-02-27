##LCZ4r Local Functions=group
##Analyze LCZ time series = name

# ------------------------------
# **1. Input Data Parameters**
# ------------------------------
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None
##QgsProcessingParameterFeatureSource|INPUT|Input data|5
##QgsProcessingParameterField|variable|Target variable column|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Column identifying stations|Table|INPUT|-1|False|False

# ------------------------------
# **2. Time Range Parameters**
# ------------------------------
##QgsProcessingParameterString|Date_start|Start date|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|End date|DD-MM-YYYY|False
##QgsProcessingParameterString|Time_frequency|Time Frequency|hour|False

# ------------------------------
# **3. Data Processing Options**
# ------------------------------
##QgsProcessingParameterEnum|Select_extract_type|Select the extract method to use|simple;two.step;bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Split data by|year;season;seasonyear;month;monthyear;weekday;weekend;dst;hour;daylight;daylight-month;daylight-season;daylight-year|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Impute missing values|mean;median;knn;bag|-1|None|True

# ------------------------------
# **4. Plot Customization**
# ------------------------------
##QgsProcessingParameterEnum|Select_plot_type|Select plot type|basic_line;facet_line;heatmap;warming_stripes|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Choose palette color|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Egypt;Greek;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronese|-1|0|False
##QgsProcessingParameterBoolean|Smooth_trend_line|Smooth trend line|False
##QgsProcessingParameterBoolean|Save_as_plot|Save as plot|True

# ------------------------------
# **5. Plot Labels and Titles**
# ------------------------------
##QgsProcessingParameterString|Title|Title|Local Climate Zones|optional|true
##QgsProcessingParameterString|xlab|xlab|Time|optional|true
##QgsProcessingParameterString|ylab|ylab|Air Temperature [ºC]|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Legend name|None|optional|true

# ------------------------------
# **6. Plot Dimensions**
# ------------------------------
##QgsProcessingParameterNumber|Height|Plot height (inches)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Plot width (inches)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Plot resolution (DPI)|QgsProcessingParameterNumber.Integer|300

# ------------------------------
# **7. Output**
# ------------------------------
##QgsProcessingParameterFileDestination|Output|Result|PNG Files (*.png)

if(!require(interp)) install.packages("interp", type = "binary")

library(LCZ4r)
library(ggplot2)
library(terra)
library(lubridate)

#Check extract method type
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
}

#Check plot type
plots <- c("basic_line", "facet_line", "heatmap", "warming_stripes")
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

# Generate data.frame ----

INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

if (Save_as_plot == TRUE) {
        plot_ts <- lcz_ts(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          time.freq = Time_frequency,
                          extract.method = result_extract,
                          smooth=Smooth_trend_line,
                          by = result_by,
                          plot_type=result_plot,
                          impute = result_imputes,
                          legend_name=Legend_name,
                          palette = result_colors,
                          iplot = TRUE, title = Title, caption = Caption, xlab = xlab, ylab = ylab)
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_ts(LCZ_map, data_frame = my_table, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = Time_frequency,
                         extract.method = result_extract,
                         by = result_by,
                         iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }

#' LCZ_map: A <b>SpatRaster</b> object derived from the <em>Download LCZ map* functions</em>
#' INPUT: A data frame (.csv) containing environmental variable data structured as follows:</p><p>
#'      :1. <b>date</b>: A column with date-time information. Ensure the column is named <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>:  A column specifying meteorological station identifiers;</p><p>
#'      :3. <b>Variable</b>: A column representing the environmental variable (e.g., air temperature, relative humidity, precipitation);</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns providing the geographical coordinates of data points. Ensure the column is named <code style='background-color: lightblue;'>lat|latitude and lon|long|longitude </code>.</p><p>
#'      :Formatting Note: Users must standardize the date-time format to R conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format i.e. “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more information, see the: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>sample data</a> 
#' variable: The name of the target variable column in the data frame (e.g., airT, RH, precip).
#' station_id: The column in the data frame identifying meteorological stations (e.g., station, site, id).
#' Date_start: Specify the start dates for the analysis. The format should be <b>DD/MM/YYYY</b>.
#' Date_end: The end date, formatted similarly to start date.
#' Time_frequency: Defines the time resolution for averageing. Default is “hour”. Supported resolutions include: “day”, “week”, “month” or “year”. Custom options such as "3 day",  "2 week" and so on. 
#' Select_extract_type: character string specifying the method used to assign the LCZ class to each station point. The default is "simple". Available methods are:</p><p>
#'      :1. <b>simple</b>: Assigns the LCZ class based on the value of the raster cell in which the point falls. It often is used in low-density observational network. </p><p>
#'      :2. <b>two.step</b>: Assigns LCZs to stations while filtering out those located in heterogeneous LCZ areas. This method requires that at least 80% of the pixels within a 5 × 5 kernel match the LCZ of the center pixel (Daniel et al., 2017). Note that this method reduces the number of stations. It often is used in ultra and high-density observational network, especially in LCZ classes with multiple stations.</p><p>
#'      :3. <b>bilinear</b>:  Interpolates the LCZ class values from the four nearest raster cells surrounding the point. </p><p>
#' Split_data_by:Determines how the time series is segmented. Options include: year, month, daylight, dst, wd (wind direction) and so on. For example, daylight split up data into daytime and nighttime periods</p><p> 
#'              :You can also use the following combination: daylight-month, daylight-season or daylight-year (make sure at least time frequency as “hour”).</p><p>
#'              :For more details, visit: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type in openair R package</a>.
#' Smooth_trend_line: Optionally, enable a smoothed trend line using a Generalized Additive Model (GAM). Defaults to FALSE.
#' Select_plot_type: Choose the visualization type. Options include:</p><p>
#'      :1. <b>basic_line</b>: Standard line chart. </p><p>
#'      :2. <b>facet_line</b>:  Line chart split into facets (LCZ or station).</p><p>
#'      :3. <b>heatmap</b>: Heatmap representation of the data. </p><p>
#'      :4. <b>warming_stripes</b>: Visualization inspired by climate warming stripes.</p><p>
#' Impute_missing_values: Method to impute missing values (“mean”, “median”, “knn”, “bag”).
#' Save_as_plot: Choose whether to save the output as a plot (TRUE) or as a table (FALSE). Remember to outputs (e.g., .jpeg for plot and .csv for table). 
#' Palette_color: Define the color palette for plots. Explore additional palettes from the <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>MetBrewer R package</a>
#' Output:If Save as plot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Example: <b>/Users/myPC/Documents/lcz_ts.jpeg</b>;</p><p>
#'       :if Save as plot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/lcz_ts.csv</b>
#' ALG_DESC: This function enables the analysis of air temperature or other environmental variables associated with Local Climate Zones (LCZ) over time.</p><p>
#'         :For detailed use cases and examples, refer to: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_time_series.html'>LCZ Local Functions (Time Series Analysis)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0