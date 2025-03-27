##LCZ4r 本地函数=group
##LCZ异常地图=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|输入LCZ地图|None
##QgsProcessingParameterFeatureSource|INPUT|输入数据|5
##QgsProcessingParameterField|variable|目标变量列|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|站点标识列|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|开始日期|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|结束日期|DD-MM-YYYY|False
##QgsProcessingParameterString|Select_hour|指定小时|0:23|optional|True
##QgsProcessingParameterEnum|Temporal_resolution|时间分辨率|小时;天;夏令时天;周;月;季节;季度;年|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|栅格分辨率|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|变异函数模型|球面;指数;高斯;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|选择提取方法|简单;两步;双线性|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|数据分组方式|年;季节;季节年;月;月年;工作日;周末;夏令时;小时;日光;日光-月;日光-季节;日光-年|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|缺失值填补|平均值;中位数;knn;bag|-1|None|True


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
        Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
         Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
} else {
    if (LCZ_interpolation){
          Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
          Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
}
 
#' LCZ_map: 来自<em>下载LCZ地图</em>函数的<b>SpatRaster</b>对象。
#' INPUT: 包含环境变量数据的框架(.csv), 结构如下:</p><p>
#'      :1. <b>date</b>: 包含日期时间信息的列。确保列名为<code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: 指定气象站标识符的列;</p><p>
#'      :3. <b>Variable</b>: 代表环境变量的列(如气温、相对湿度);</p><p>
#'      :4. <b>纬度和经度</b>: 提供地理坐标的两列。确保列名为<code style='background-color: lightblue;'>lat|latitude和lon|long|longitude</code>。</p><p>
#'      :格式注意: 日期时间格式必须符合R惯例，如<b style='text-decoration: underline;'>2023-03-13 11:00:00</b>或<b style='text-decoration: underline;'>2023-03-13</b>。也可接受"1/2/1999"或"DD/MM/YYYY"、"1999-02-01"等格式。</p><p>
#'      :更多信息请参阅: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>示例数据</a>。
#' variable: 数据框中目标变量列的名称(如airT、RH、precip)。
#' station_id: 数据框中识别气象站的列(如station、site、id)。
#' Date_start: 指定分析开始日期，格式为<b>DD/MM/YYYY</b>。例如01-09-1986。
#' Date_end: 结束日期，格式同开始日期。
#' Select_hour: 指定0到23时的小时或小时范围。可使用以下格式:</p><p>
#'      :范围: 0:12选择0到12时;</p><p>
#'      :特定集合: c(1,6,18,21)选择1、6、18和21时;</p><p>
#'      :若数据为日、月或年尺度，此参数留空。
#' Raster_resolution: 空间插值分辨率(米)。默认为100。
#' Temporal_resolution: 定义平均时间分辨率。默认为"小时"。支持的分辨率包括:"小时"、"天"、"夏令时天"、"周"、"月"、"季度"或"年"。
#' Select_extract_type: 指定LCZ类分配方法的字符串。默认为"简单"。可用方法:</p><p>
#'      :1. <b>简单</b>: 根据站点所在栅格像元值分配LCZ类。常用于低密度观测网络。</p><p>
#'      :2. <b>两步</b>: 在分配LCZ时过滤位于异质LCZ区域的站点。要求5×5核内至少80%像元与中心像元LCZ匹配(Daniel等,2017)。会减少站点数量。</p><p>
#'      :3. <b>双线性</b>: 从站点周围四个最近栅格像元插值LCZ类值。</p><p>
#' Split_data_by: 确定时间序列分段方式。选项包括:年、月、日光、夏令时(dst)、风向(wd)等。"日光"将数据分为白天和夜间时段。</p><p>
#'              :也可使用组合:日光-月、日光-季节或日光-年(确保时间分辨率至少为"小时")。</p><p>
#'              :详情访问: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>openair R包中的type参数</a>。
#' Viogram_model: 如选择克里金，将测试的变异函数模型列表。默认为"球面"。模型包括"球面"、"指数"、"高斯"、"Ste"(Matern族，Stein参数化)。
#' Impute_missing_values: 填补缺失值的方法("平均值"、"中位数"、"knn"、"bag")。
#' LCZ_interpolation: 如为TRUE(默认)，使用LCZ插值方法。如为FALSE，使用常规插值(不含LCZ)。
#' Output: terra格式的GeoTIF栅格。
#' ALG_DESC: 本函数生成不同局地气候区(LCZ)热力异常的图形表示。</p><p>
#'         :更多信息请访问: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling.html#interpolating-thermal-anomalies-with-lcz'>LCZ局部函数(基于LCZ的热力异常插值)</a>。
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a>。
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>。
#' ALG_VERSION: 0.1.0