##LCZ4r Local Functions=group
##Modelling LCZ anomaly =name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None
##QgsProcessingParameterFeatureSource|INPUT|Input data|5
##QgsProcessingParameterField|variable|Target variable column|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Column identifying stations|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Start date|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|End date|DD-MM-YYYY|False
##QgsProcessingParameterString|Select_hour|Specific a hour|0:23|optional|True
##QgsProcessingParameterEnum|Split_data_by|Split data by|year;season;seasonyear;month;monthyear;weekday;weekend;dst;hour;daylight;daylight-month;daylight-season;daylight-year|-1|None|True
##QgsProcessingParameterEnum|Viogram_model|Vioagram model|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Temporal_resolution|Temporal resolution|hour;day;week;quater;year|5|0|False
##QgsProcessingParameterNumber|Raster_resolution|Raster resolution|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Impute_missing_values|Impute missing values|mean;median;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|LCZ-kringing interpolation|True
##QgsProcessingParameterRasterDestination|Output|Result

if(!require(interp)) install.packages("interp", type = "binary")


library(LCZ4r)
library(ggplot2)
library(terra)
library(lubridate)

#Check method type
methods <- c("Sph", "Exp", "Gau", "Ste")
if (!is.null(Viogram_model) && Viogram_model >= 0 && Viogram_model < length(methods)) {
  result_methods <- methods[Viogram_model + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_methods <- NULL  # Handle invalid or missing selection
}

temp_res <- c("hour", "day", "week", "quater", "year")
if (!is.null(Temporal_resolution) && Temporal_resolution >= 0 && Temporal_resolution < length(temp_res)) {
  result_temp <- temp_res[Temporal_resolution + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_temp <- NULL  # Handle invalid or missing selection
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
   # Check if Hour contains a colon and split accordingly
    if (grepl(":", Select_hour)) { 
  # Directly convert to numeric range
    Select_hour <- as.numeric(unlist(strsplit(Select_hour, ":")))  # Split and convert to numeric
    Select_hour <- Select_hour[1]:Select_hour[2]  # Create a range from start to end hour
    } else if (grepl(",", Select_hour)) {
    Select_hour <- as.numeric(unlist(strsplit(gsub("c\\(|\\)", "", Select_hour), ",")))
    } else {
    Select_hour <- as.numeric(Select_hour)  # Convert to numeric if not a range
    }
    if (LCZ_interpolation) {
        Output=lcz_anomaly_map(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_temp,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
        Output=lcz_anomaly_map(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_temp,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
} else {
    if (LCZ_interpolation){
         Output=lcz_anomaly_map(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_temp,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
         Output=lcz_anomaly_map(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_temp,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
}
 
#' LCZ_map: A <b>SpatRaster</b> object derived from the <em>Download LCZ map* functions</em>
#' INPUT: A data frame (.csv) containing environmental variable data structured as follows:</p><p>
#'      :1. <b>date</b>: A column with date-time information. Ensure the column is named <code style='background-color: lightblue;'>date</code>.;</p><p>
#'      :2. <b>Station</b>:  A column specifying meteorological station identifiers.;</p><p>
#'      :3. <b>Variable</b>: A column representing the environmental variable (e.g., air temperature, relative humidity, precipitation);</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns providing the geographical coordinates of data points.</p><p>
#'      :Formatting Note: Users must standardize the date-time format to R conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format i.e. “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more information, see the: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>sample data</a> 
#' variable: The name of the target variable column in the data frame (e.g., airT, RH, precip).
#' station_id: The column in the data frame identifying meteorological stations (e.g., station, site, id).
#' Date_start: Specify the start dates for the analysis. The format should be <b>DD/MM/YYYY</b>. E.g., 01-09-1986.
#' Date_end: The end date, formatted similarly to start date.
#' Time_frequency: Defines the time period for averaging. Default is "hour", but options include "day", "week", "month", "season", "year", or even "3 hour", "2 day", "3 month", etc.
#' Split_data_by:Determines how the time series is segmented. Options include: year, month, daylight, dst, wd (wind direction) and so on. For example, daylight split up data into daytime and nighttime periods</p><p> 
#'              :You can also use the following combination: daylight-month, daylight-season or daylight-year (make sure at least Time_resolution as “hour”).</p><p>
#'              :For more details, visit: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type in openair R package</a>.
#' Select_hour: An hour or hours to select from 0-23 e.g. hour = 0:12 to select hours 0 to 12 inclusive. You also can use the following: "c(1, 6, 18, 21)".   
#' Raster_resolution:Spatial resolution in unit of meters for interpolation. Default is 100.
#' Temporal_resolution: Defines the time period for averaging. Default is "hour", but options include "day", "week", "month", "season", "year", or even "3 hour", "2 day", "3 month", etc.
#' Viogram_model: If kriging is selected, the list of viogrammodels that will be tested and interpolated with kriging. Default is "Sph". The model are "Sph", "Exp", "Gau", "Ste". They names respective shperical, exponential, gaussian, Matern familiy, Matern, M. Stein's parameterization.
#' Impute_missing_values: Method to impute missing values in data (“mean”, “median”, “knn”, “bag”).
#' LCZ_interpolation: If set to TRUE (default), the LCZ interpolation approach is used. If set to FALSE, conventional interpolation without LCZ is used.
#' Output: A raster in terra GeoTIF format
#' ALG_DESC:This function generates a graphical representation of thermal anomaly for different Local Climate Zones (LCZs).</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling.html#interpolating-thermal-anomalies-with-lcz'>LCZ Local Functions (Interpolating thermal anomalies with LCZ)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0