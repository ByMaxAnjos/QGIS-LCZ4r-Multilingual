##LCZ4r Local functions=group
##Interpolate LCZ anomaly=name
##dont_load_any_packages
##pass_filenames
##LCZ_map=raster
##Data_inputs=File
##Variable=string airT
##Station_id=string station
##Date_start=optional datetime 
##Date_end=optional datetime
##Select_hour=optional string
##Split_data_by=optional enum literal year;season;seasonyear;month;monthyear;weekday;weekend;dst;hour;daylight;daylight-month;daylight-season;daylight-year
##Impute_missing_values=optional enum literal mean;median;knn;bag
##Raster_resolution=number 100
##Temporal_resolution=string hour
##Viogram_model=enum literal Sph;Exp;Gau;Ste
##LCZ_interpolation=boolean TRUE
##Output=output raster
##ByMaxAnjos/LCZ4r=github_install


if(!require(data.table)) install.packages("data.table")
library(LCZ4r)
library(terra)
library(sf)
library(data.table)

# Generate and plot or data.frame ----
my_table <- fread(Data_inputs)
LCZ_map <- terra::rast(LCZ_map)


# Check for date conditions by

if ("daylight-month" %in% Split_data_by) {
    Split_data_by <- c("daylight", "month")
}
if ("daylight-season" %in% Split_data_by) {
    Split_data_by <- c("daylight", "season")
}
if ("daylight-year" %in% Split_data_by) {
    Split_data_by <- c("daylight", "year")
}

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
                          start = Date_start, end = Date_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = Temporal_resolution,
                          vg.model = Viogram_model,
                          by = Split_data_by,
                          impute = Impute_missing_values,
                          LCZinterp = TRUE
                          )
    } else {
        Output=lcz_anomaly_map(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = Date_start, end = Date_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = Temporal_resolution,
                          vg.model = Viogram_model,
                          by = Split_data_by,
                          impute = Impute_missing_values,
                          LCZinterp = FALSE
                          )
    }
} else {
    if (LCZ_interpolation){
         Output=lcz_anomaly_map(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = Date_start, end = Date_end,
                          sp.res = Raster_resolution,
                          tp.res = Temporal_resolution,
                          vg.model = Viogram_model,
                          by = Split_data_by,
                          impute = Impute_missing_values,
                          LCZinterp = TRUE
                          )
    } else {
         Output=lcz_anomaly_map(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = Date_start, end = Date_end,
                          sp.res = Raster_resolution,
                          tp.res = Temporal_resolution,
                          vg.model = Viogram_model,
                          by = Split_data_by,
                          impute = Impute_missing_values,
                          LCZinterp = FALSE
                          )
    }
}
 
#' LCZ_map: A <b>SpatRaster</b> from <em>Obtain LCZ map functions</em>
#' Data_inputs: A data frame (.csv) containing data on air temperature (or any other environmental variable) structured as follows:</p><p>
#'      :1. <b>date</b>: This column should contain date-time information, whose  column MUST be named as <code style='background-color: lightblue;'>date</code>;</p><p>
#'      :2. <b>Station</b>: Designate a column for meteorological station identifiers;</p><p>
#'      :3. <b>Variable</b>: At least one column representing air temperature variable;</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns are required to specify the geographical coordinates.</p><p>
#'      :It’s important to note that the users should standardize the date-time format to R’s conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more details, see: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>LCZ local functions</a> 
#' Variable: The name of the variable in the data frame representing the air temperature column ("airT", "RH", "precip").
#' Station_id: The name of the variable in the data frame representing the station IDs column ("station", "site", "id").
#' Date_start: A start date in the format "01/09/1986 00:00". Please do not change the time to anything other than "00:00".
#' Date_end: An end date, formatted similarly to Date_start.
#' Select_hour:An hour or hours to select from 0-23 e.g. hour = 0:12 to select hours 0 to 12 inclusive. You also can use the following: "c(1, 6, 18, 21)".   
#' Split_data_by:Specifies how to split the time series in the data frame. Options include, among ohters, year, month, daylight, dst, wd (wind direction) and so on. For example, daylight split up data into daytime and nighttime periods</p><p> 
#'              :You can also use the following combination: daylight-month, daylight-season or daylight-year (make sure at least Time resolution as “hour”).</p><p>
#'              :For more details, visit: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type in openair R package</a>.
#' Raster_resolution:Spatial resolution in unit of meters for interpolation. Default is 100.
#' Temporal_resolution: Defines the time period for averaging. Default is "hour", but options include "day", "week", "month", "season", "year", or even "3 hour", "2 day", "3 month", etc.
#' Viogram_model: If kriging is selected, the list of viogrammodels that will be tested and interpolated with kriging. Default is "Sph". The model are "Sph", "Exp", "Gau", "Ste". They names respective shperical, exponential, gaussian, Matern familiy, Matern, M. Stein's parameterization.
#' Impute_missing_values:Method to impute missing values in data (“mean”, “median”, “knn”, “bag”).
#' LCZ_interpolation: If set to TRUE (default), the LCZ interpolation approach is used. If set to FALSE, conventional interpolation without LCZ is used.
#' Output: A raster in terra GeoTIF format
#' ALG_DESC:This function generates a graphical representation of thermal anomaly for different Local Climate Zones (LCZs).</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>LCZ local functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0