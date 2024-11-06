##LCZ4r Local functions=group
##Calculate LCZ anomaly=name
##dont_load_any_packages
##pass_filenames
##LCZ_map=raster
##Data_input=File 
##Variable=string airT
##Station_id=string station
##Date_start=optional datetime 
##Date_end=optional datetime
##Select_hour=optional string
##Time_frequency=string hour
##Select_plot_type=enum literal diverging_bar;bar;dot;lollipop diverging_bar
##Split_data_by=optional enum literal year;season;seasonyear;month;monthyear;weekday;weekend;dst;hour;daylight;daylight-month;daylight-season;daylight-year
##Impute_missing_values=optional enum literal mean;median;knn;bag
##Save_as_plot=boolean TRUE
##Palette_color=enum literal OKeeffe1;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Egypt;Greek;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;VanGogh2;Veronese OKeeffe1
##Title_plot=string LCZ anomalies
##xlab=string Stations
##ylab=string Air Temperature [ºC]
##Caption=string Source:LCZ4r, 2024.
##Legend_name=string Anomaly [ºC]
##Height=number 7
##Width=number 10
##dpi=number 300
##Output=output File png

if(!require(data.table)) install.packages("data.table")
if(!require(interp)) install.packages("interp", type = "binary")


library(LCZ4r)
library(ggplot2)
library(data.table)
library(terra)

# Generate and plot or data.frame ----
my_table <- fread(Data_input)
LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(Date_start, "%d/%m/%Y")
formatted_end <- format(Date_end, "%d/%m/%Y")

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
    if (Save_as_plot) {
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          time.freq = Time_frequency, 
                          by = Split_data_by,
                          plot_type=Select_plot_type,
                          impute = Impute_missing_values,
                          legend_name=Legend_name,
                          palette = Palette_color,
                          iplot = TRUE, title = Title_plot, caption = Caption, xlab = xlab, ylab = ylab)
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                         start = formatted_start, end = formatted_end, hour=Select_hour,
                         time.freq = Time_frequency,
                         by = Split_data_by,
                         impute = Impute_missing_values, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
} else {
    if (Save_as_plot){
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = formatted_start, end = formatted_end,  hour=Select_hour,
                          time.freq = Time_frequency, 
                          by = Split_data_by,
                          impute = Impute_missing_values,
                          iplot = TRUE, title = Title_plot, caption = Caption, xlab = xlab, ylab = ylab)
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                         start = formatted_start, end = formatted_end,  hour=Select_hour,
                         time.freq = Time_frequency,
                         by = Split_data_by,
                         impute = Impute_missing_values, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
}
 

#' LCZ_map: A <b>SpatRaster</b> from <em>Download LCZ map* functions</em>
#' Data_input: A data frame (.csv) containing data on air temperature (or any other environmental variable) structured as follows:</p><p>
#'      :1. <b>date</b>: This column should contain date-time information, whose column MUST be named as <code style='background-color: lightblue;'>date</code>;</p><p>
#'      :2. <b>Station</b>: Designate a column for meteorological station identifiers;</p><p>
#'      :3. <b>Variable</b>: At least one column representing air temperature variable;</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns are required to specify the geographical coordinates.</p><p>
#'      :It’s important to note that the users should standardize the date-time format to R’s conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format: “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more details, see: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>sample data</a> 
#' Variable: The name of the variable in the data frame representing the air temperature column ("airT", "RH", "precip").
#' Station_id: The name of the variable in the data frame representing the station IDs column ("station", "site", "id").
#' Date_start: A start date in the format "01/09/1986 00:00". Please do not change the time to anything other than "00:00".
#' Date_end: An end date, formatted similarly to Date_start.
#' Select_hour:An hour or hours to select from 0-23 e.g. hour = 0:12 to select hours 0 to 12 inclusive. You also can use the following: "c(1, 6, 18, 21)".   
#' Time_frequency: Defines the time period for averaging. Default is "hour", but options include "day", "week", "month", "season", "year", or even "3 hour", "2 day", "3 month", etc.
#' Select_plot_type: Choose from:</p><p>
#'      :1. <b>diverging_bar</b>: A horizontal bar plot that diverges from the center (zero), with positive anomalies extending to the right and negative anomalies to the left. This plot is good for showing the extent and direction of anomalies in a compact format;</p><p>
#'      :2. <b>bar</b>:A bar plot showing the magnitude of the anomaly for each station, colored by whether the anomaly is positive or negative. This plot is good for comparing anomalies across stations;</p><p>
#'      :3. <b>dot</b>: A dot plot that displays both the mean temperature values and the reference values, with lines connecting them. The size or color of the dots can indicate the magnitude of the anomaly. Ideal for showing both absolute temperature values and their anomalies;</p><p>
#'      :4. <b>lollipop</b>: A lollipop plot where each "stick" represents an anomaly value and the dots at the top represent the size of the anomaly. Useful for clearly showing positive and negative anomalies in a minimalist way.</p><p>
#' Split_data_by:Specifies how to split the time series in the data frame. Options include, among ohters, year, month, daylight, dst, wd (wind direction) and so on. For example, daylight split up data into daytime and nighttime periods</p><p> 
#'              :You can also use the following combination: daylight-month, daylight-season or daylight-year (make sure at least Time resolution as “hour”).</p><p>
#'              :For more details, visit: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type in openair R package</a>.
#' Impute_missing_values:Method to impute missing values in data: “mean”, “median”, “knn”, “bag”.
#' Save_as_plot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs (e.g., .jpeg for plot and .csv for table). 
#' Palette_color: The default is “OKeeffe1”. You can choose from palettes available in <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>MetBrewer</a>
#' Output:1. If Save_as_plot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Example: <b>/Users/myPC/Documents/lcz_ts.jpeg</b>;</p><p>
#'       :2. if Save_as_plot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/lcz_ts.csv</b>
#' ALG_DESC:This function caluculates thermal anomaly for different Local Climate Zones (LCZs).</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_anomaly.html'>LCZ Local Functions(Thermal Anomalies)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0