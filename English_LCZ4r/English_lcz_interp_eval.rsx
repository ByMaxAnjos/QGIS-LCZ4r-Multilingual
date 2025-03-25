##LCZ4r Local Functions=group
##Evaluate LCZ Interpolation=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None
##QgsProcessingParameterFeatureSource|INPUT|Input data|5
##QgsProcessingParameterField|variable|Target variable column|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Column identifying stations|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Start date|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|End date|DD-MM-YYYY|False
##QgsProcessingParameterBoolean|Select_Anomaly|Evaluate Anomaly|FALSE
##QgsProcessingParameterBoolean|Select_LOOCV|LOOCV (leave-one-out cross validation)|True
##QgsProcessingParameterNumber|SplitRatio|Train/test split station proportion (if LOOCV is false)|QgsProcessingParameterNumber.Double|0.8
##QgsProcessingParameterEnum|Temporal_resolution|Temporal resolution|hour;day;DSTday;week;month;season;quater;year|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Raster resolution|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Vioagram model|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Select the extract method to use|simple;two.step;bilinear|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Impute missing values|mean;median;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|LCZ-kringing interpolation|True
##QgsProcessingParameterFileDestination|Output|Save your table|Files (*.csv)


library(LCZ4r)
library(ggplot2)
library(terra)
library(lubridate)


#Check extract method type
time_options <- c("hour", "day", "DSTday", "week", "month", "season", "quater", "year")
if (!is.null(Temporal_resolution) && Temporal_resolution >= 0 && Temporal_resolution < length(time_options)) {
  result_time <- time_options[Temporal_resolution + 1]  # Add 1 to align with R's 1-based indexing
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

#Check method type
methods <- c("Sph", "Exp", "Gau", "Ste")
if (!is.null(Viogram_model) && Viogram_model >= 0 && Viogram_model < length(methods)) {
  result_methods <- methods[Viogram_model + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_methods <- NULL  # Handle invalid or missing selection
}

#Check impute missing values
imputes <- c("mean", "median", "knn", "bag")
if (!is.null(Impute_missing_values) && Impute_missing_values >= 0 && Impute_missing_values < length(imputes)) {
  result_imputes <- imputes[Impute_missing_values + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_imputes <- NULL  # Handle invalid or missing selection
}


# Generate and plot or data.frame ----
INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

# Check if Hour is an empty string and handle accordingly
    if (LCZ_interpolation) {
        eval_lcz=lcz_interp_eval(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          LOOCV = Select_LOOCV,
                          split.ratio = SplitRatio,
                          Anomaly = Select_Anomaly,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          #by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    write.csv(eval_lcz, Output, row.names = FALSE)
    } else {
         Output=lcz_interp_eval(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          LOOCV = Select_LOOCV,
                          split.ratio = SplitRatio,
                          Anomaly = Select_Anomaly,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          #by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    write.csv(eval_lcz, Output, row.names = FALSE)
    }
 
#' LCZ_map: A <b>SpatRaster</b> object derived from the <em>Download LCZ map* functions</em>
#' INPUT: A data frame (.csv) containing environmental variable data structured as follows:</p><p>
#'      :1. <b>date</b>: A column with date-time information. Ensure the column is named <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>:  A column specifying meteorological station identifiers;</p><p>
#'      :3. <b>Variable</b>: A column representing the environmental variable (e.g., air temperature, relative humidity, precipitation);</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns providing the geographical coordinates of data points. Ensure the column is named <code style='background-color: lightblue;'>lat|latitude and lon|long|longitude </code>.</p><p>
#'      :Formatting Note: Users must standardize the date-time format to R conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format i.e. “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more information, see the: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>sample data</a> 
#' Variable: The name of the target variable column in the data frame (e.g., airT, RH, precip).
#' Station_id: The column in the data frame identifying meteorological stations (e.g., station, site, id).
#' Date_start: Specify the start dates for the analysis. The format should be <b>DD/MM/YYYY</b>.
#' Date_end: The end date, formatted similarly to start date.
#' Select_Anomaly: If TRUE,the anomalies are calculated. If FALSE (default) the raw air temperatures are used. 
#' Select_LOOCV: If TRUE (default), leave-one-out cross-validation (LOOCV) is used for kriging. If FALSE, the split method into training and testing stations is used. 
#' SplitRatio: A numeric value representing the proportion of meteorological stations to be used for training (interpolation). The remaining stations will be used for testing (evaluation). For example, the default 0.8 indicates that 80% of the stations will be used for training and 20% for testing. 
#' Raster_resolution: Spatial resolution in unit of meters for interpolation. Default is 100.
#' Temporal_resolution: Defines the time resolution for averageing. Default is “hour”. Supported resolutions include: “hour”, “day”, “DSTday”, “week”, “month”, “quarter” or “year”.
#' Select_extract_type: character string specifying the method used to assign the LCZ class to each station point. The default is "simple". Available methods are:</p><p>
#'      :1. <b>simple</b>: Assigns the LCZ class based on the value of the raster cell in which the point falls. It often is used in low-density observational network. </p><p>
#'      :2. <b>two.step</b>: Assigns LCZs to stations while filtering out those located in heterogeneous LCZ areas. This method requires that at least 80% of the pixels within a 5 × 5 kernel match the LCZ of the center pixel (Daniel et al., 2017). Note that this method reduces the number of stations. It often is used in ultra and high-density observational network, especially in LCZ classes with multiple stations.</p><p>
#'      :3. <b>bilinear</b>:  Interpolates the LCZ class values from the four nearest raster cells surrounding the point. </p><p>
#' Viogram_model: If kriging is selected, the list of viogrammodels that will be tested and interpolated with kriging. Default is "Sph". The model are "Sph", "Exp", "Gau", "Ste". They names respective shperical, exponential, gaussian, Matern familiy, Matern, M. Stein's parameterization.
#' Impute_missing_values: Method to impute missing values in data (“mean”, “median”, “knn”, “bag”).
#' LCZ_interpolation: If set to TRUE (default), the LCZ interpolation approach is used. If set to FALSE, conventional kriging interpolation without LCZ is used.
#' Output: Specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/lcz_eval.csv</b>
#' ALG_DESC:This function evaluates the variability of a spatial and temporal interpolation of a variable (e.g., air temperature) using LCZ as background. It supports both LCZ-based and conventional interpolation methods. The function allows for flexible time period selection, cross-validation, and station splitting for training and testing.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling_eval.html'>Evaluating LCZ-based Interpolation</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0