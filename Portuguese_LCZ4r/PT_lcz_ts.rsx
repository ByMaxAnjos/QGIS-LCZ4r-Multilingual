##LCZ4r Local functions=group
##Peforme LCZ time series=name
##dont_load_any_packages
##pass_filenames
##LCZ_map=raster
##Data_inputs=File
##Variable=string airT
##Station_id=string station
##Date_start=optional datetime 
##Date_end=optional datetime
##Time_frequency=string hour
##Split_data_by=optional enum literal year;season;seasonyear;month;monthyear;weekday;weekend;dst;hour;daylight;daylight-month;daylight-season;daylight-year
##Impute_missing_values=optional enum literal mean;median;knn;bag
##iPlot=boolean TRUE
##Title_plot=string LCZ time-series
##xlab=string Date
##ylab=string Air Temperature [ºC]
##Caption=string Source:LCZ4r, 2024.
##Height=number 7
##Width=number 10
##dpi=number 300
##Palette_color=string VanGogh
##Output=output File
##ByMaxAnjos/LCZ4r=github_install


if(!require(data.table)) install.packages("data.table")
library(LCZ4r)
library(ggplot2)
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

if (iPlot == TRUE) {
        plot_ts <- lcz_ts(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                          start = Date_start, end = Date_end,
                          time.freq = Time_frequency, 
                          by = Split_data_by,
                          impute = Impute_missing_values,
                          iplot = TRUE, title = Title_plot, caption = Caption, xlab = xlab, ylab = ylab)
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_ts(LCZ_map, data_frame = my_table, var = Variable, station_id = Station_id,
                         start = Date_start, end = Date_end,
                         time.freq = Time_frequency,
                         by = Split_data_by,
                         impute = Impute_missing_values, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }

#' LCZ_map: A <b>SpatRaster</b> from <em>Obtain LCZ map functions</em>
#' Data_inputs: A data frame (.csv) containing data on air temperature (or any other environmental variable) structured as follows:</p><p>
#'      :1. <b>date</b>: This column should contain date-time information, whose column MUST be named as <code style='background-color: lightblue;'>date</code>;</p><p>
#'      :2. <b>Station</b>: Designate a column for meteorological station identifiers;</p><p>
#'      :3. <b>Variable</b>: At least one column representing air temperature variable;</p><p>
#'      :4. <b>Latitude and Longitude </b>: Two columns are required to specify the geographical coordinates.</p><p>
#'      :It’s important to note that the users should standardize the date-time format to R’s conventions, such as <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> or <b style='text-decoration: underline;'>2023-03-13</b>. It also includes: e.g. “1/2/1999” or in format i.e. “YYYY-mm-dd”, “1999-02-01”.</p><p>
#'      :For more details, see: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>sample data</a> 
#' Variable: The name of the variable in the data frame representing the air temperature column ("airT", "RH", "precip").
#' Station_id: The name of the variable in the data frame representing the station IDs column ("station", "site", "id").
#' Date_start: A start date in the format "01/09/1986 00:00". Please do not change the time to anything other than "00:00".
#' Date_end: An end date, formatted similarly to Date_start.
#' Time_frequency:An hour or hours to select from 0-23 e.g. hour = 0:12 to select hours 0 to 12 inclusive. You also can use the following: "c(1, 6, 18, 21)".   
#' Split_data_by:Specifies how to split the time series in the data frame. Options include, among ohters, year, month, daylight, dst, wd (wind direction) and so on. For example, daylight split up data into daytime and nighttime periods</p><p> 
#'              :You can also use the following combination: daylight-month, daylight-season or daylight-year (make sure at least Time_resolution as “hour”).</p><p>
#'              :For more details, visit: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type in openair R package</a>.
#' Impute_missing_values:Method to impute missing values (“mean”, “median”, “knn”, “bag”).
#' iPlot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs (e.g., .jpeg for plot and .csv for table). 
#' Palette_color: Default is "VanGogh2". Define your color palette from <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>MetBrewer R package</a>
#' Output:If iPlot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Example: <b>/Users/myPC/Documents/lcz_ts.jpeg</b>;</p><p>
#'       :if iPlot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/lcz_ts.csv</b>
#' ALG_DESC:This function generates a graphical representation of thermal anomaly for different Local Climate Zones (LCZs).</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>LCZ local functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0