##LCZ4r Local Functions=group
##Analyze Urban Heat Island Intensity=name
##pass_filenames
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
##QgsProcessingParameterEnum|Impute_missing_values|Impute missing values|mean;median;knn;bag|-1|None|True

# ------------------------------
# **3. Data Processing Options**
# ------------------------------
##QgsProcessingParameterEnum|Method|Select the UHI method to use|LCZ;manual|-1|0|False
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|Display urban and rural stations|True
##QgsProcessingParameterEnum|Select_extract_type|Select the extract method to use|simple;two.step;bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Split data by|year;season;seasonyear;month;monthyear;weekday;weekend;dst;hour;daylight;daylight-month;daylight-season;daylight-year|-1|None|True
##QgsProcessingParameterString|Urban_station_reference|Urban station reference|None|optional|true
##QgsProcessingParameterString|Rural_station_reference|Rural station reference|None|optional|true
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|Display urban and rural stations|True

# ------------------------------
# **5. Plot Labels and Titles**
# ------------------------------
##QgsProcessingParameterBoolean|display|Visualize plot(.html)|True
##QgsProcessingParameterString|Title|Title|Local Climate Zones|optional|true
##QgsProcessingParameterString|xlab|xlab|Time|optional|true
##QgsProcessingParameterString|ylab|ylab|Air Temperature [ºC]|optional|true
##QgsProcessingParameterString|ylab2|ylab2|UHI[ºC]|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true

# ------------------------------
# **6. Plot Dimensions**
# ------------------------------
##QgsProcessingParameterNumber|Height|Plot height (inches)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Plot width (inches)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Plot resolution (DPI)|QgsProcessingParameterNumber.Integer|300

# ------------------------------
# **7. Output**
# ------------------------------
##QgsProcessingParameterBoolean|Save_as_plot|Save as plot|True
##QgsProcessingParameterFileDestination|Output|Save your image|PNG Files (*.png)

if(!require(interp)) install.packages("interp", type = "binary")
if(!require(DT)) install.packages("DT")


library(LCZ4r)
library(sf)
library(ggplot2)
library(terra)
library(lubridate)
library(ggiraph)
library(htmlwidgets)
library(DT)

#Check extract method type
uhi_methods <- c("LCZ", "manual")
if (!is.null(Method) && Method >= 0 && Method < length(uhi_methods)) {
  result_method <- uhi_methods[Method + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_method <- NULL  
}

#Check extract method type
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
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
        plot_uhi <- lcz_uhi_intensity(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                        start = formatted_start, end = formatted_end,
                        time.freq = Time_frequency, 
                        by = result_by,
                        extract.method = result_extract,
                        method = result_method,
                        Turban= Urban_station_reference,
                        Trural= Rural_station_reference,
                        group = Group_urban_and_rural_temperatures,
                        impute = result_imputes,
                        iplot = TRUE, 
                        title = Title, caption = Caption, xlab = xlab, ylab = ylab, ylab2 = ylab2)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_uhi,
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
        ggsave(Output, plot_uhi, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_uhi <- lcz_uhi_intensity(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                        time.freq = Time_frequency, 
                        by = result_by,
                        extract.method = result_extract,
                        method = result_method,
                        Turban= Urban_station_reference,
                        Trural= Rural_station_reference,
                        group = Group_urban_and_rural_temperatures,
                        impute = result_imputes, 
                        iplot = FALSE)
        write.csv(tbl_uhi, Output, row.names = FALSE)
    }

#' LCZ_map: A <b>SpatRaster</b> object derived from the <em>Download LCZ map* functions</em>
#' INPUT: A data frame (.csv) containing environmental variable data structured as follows:</p><p>
#'      :1. <b>date</b>: A column with date-time information. Ensure the column is named <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>:  A column specifying meteorological station identifiers;</p><p>
#'      :3. <b>Variable</b>: A column representing the environmental variable (e.g., air temperature, relative humidity, precipitation);</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns providing the geographical coordinates of data points. Ensure the column is named <code style='background-color: lightblue;'>lat|latitude and lon|long|longitude </code>.</p><p>
#'      :Formatting Note: Users must standardize the date-time format to R conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format i.e. “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more information, see the: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>sample data</a> 
#' variable: The name of the target variable column in the data frame (e.g., airT).
#' station_id: The column in the data frame identifying meteorological stations (e.g., station, site, id).
#' Date_start: Specify the start dates for the analysis. The format should be <b>DD/MM/YYYY</b>.
#' Date_end: The end date, formatted similarly to start date.
#' Time_frequency: Defines the time resolution for averageing. Default is “hour”. Supported resolutions include: “day”, “week”, “month” or “year”. Custom options such as "3 day",  "2 week" and so on. 
#' Impute_missing_values:Method to impute missing values (“mean”, “median”, “knn”, “bag”).
#' Select_extract_type: character string specifying the method used to assign the LCZ class to each station point. The default is "simple". Available methods are:</p><p>
#'      :1. <b>simple</b>: Assigns the LCZ class based on the value of the raster cell in which the point falls. It often is used in low-density observational network. </p><p>
#'      :2. <b>two.step</b>: Assigns LCZs to stations while filtering out those located in heterogeneous LCZ areas. This method requires that at least 80% of the pixels within a 5 × 5 kernel match the LCZ of the center pixel (Daniel et al., 2017). Note that this method reduces the number of stations. It often is used in ultra and high-density observational network, especially in LCZ classes with multiple stations.</p><p>
#'      :3. <b>bilinear</b>:  Interpolates the LCZ class values from the four nearest raster cells surrounding the point. </p><p>
#' Split_data_by:Determines how the time series is segmented. Options include: year, month, daylight, dst, wd (wind direction) and so on. For example, daylight split up data into daytime and nighttime periods</p><p> 
#'              :You can also use the following combination: daylight-month, daylight-season or daylight-year (make sure at least time frequency as “hour”).</p><p>
#'              :For more details, visit: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type in openair R package</a>.
#' Method:Method to calculate the UHI intensity. Options include "LCZ" and "manual". In the LCZ method, the functions automatically identifies the LCZ build types, starting from LCZ 1 and progressing to LCZ 10, to represent the urban temperature, whilst it starts from LCZ natural LCZ (11-16) to represent the rural temperature.</p><p>
#'       :In the manual method, users have the freedom to select stations as references for the urban and rural areas.
#' Urban_station_reference: If the method "manual" is selected, select urban reference in <b>station_id</b> column 
#' Rural_station_reference:If the method "manual" is selected, select rural reference in <b>station_id</b> column 
#' Group_urban_and_rural_temperatures: If TRUE, urban and rural air temperatures are grouped in the same plot.
#' display: If TRUE, the plot will be displayed in your web browser as an HTML visualization.
#' Save_as_plot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs .jpeg for plot and .csv for table. 
#' Output:If Save as plot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Example: <b>/Users/myPC/Documents/lcz_uhi.png</b>;</p><p>
#'       :if Save as plot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/lcz_uhi.csv</b>
#' ALG_DESC:This function calculates the Urban Heat Island (UHI) intensity based on air temperature measurements and Local Climate Zones (LCZ).</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_uhi.html'>LCZ Local Functions (Urban Heat Island (UHI) Analysis)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0