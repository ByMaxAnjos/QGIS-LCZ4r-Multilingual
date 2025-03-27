##LCZ4r 本地函数=group
##评估LCZ插值=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|输入LCZ地图|None
##QgsProcessingParameterFeatureSource|INPUT|输入数据|5
##QgsProcessingParameterField|variable|目标变量列|表格|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|站点标识列|表格|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|开始日期|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|结束日期|DD-MM-YYYY|False
##QgsProcessingParameterBoolean|Select_Anomaly|评估异常|FALSE
##QgsProcessingParameterBoolean|Select_LOOCV|LOOCV (留一交叉验证)|True
##QgsProcessingParameterNumber|SplitRatio|训练/测试站比例(如LOOCV为假)|QgsProcessingParameterNumber.Double|0.8
##QgsProcessingParameterEnum|Temporal_resolution|时间分辨率|小时;天;夏令时天;周;月;季节;季度;年|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|栅格分辨率|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|变异函数模型|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|选择提取方法|简单;两步;双线性|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|填补缺失值|平均值;中位数;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|LCZ克里金插值|True
##QgsProcessingParameterFileDestination|Output|保存表格|文件 (*.csv)


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
 
#' LCZ_map: 从<em>下载LCZ地图</em>函数派生的<b>SpatRaster</b>对象。
#' INPUT: 包含环境变量数据的框架(.csv),结构如下:</p><p>
#'      :1. <b>date</b>: 包含日期时间信息的列。确保列名为<code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: 指定气象站标识符的列;</p><p>
#'      :3. <b>Variable</b>: 表示环境变量(如气温、相对湿度、降水)的列;</p><p>
#'      :4. <b>纬度和经度</b>: 提供数据点地理坐标的两列。确保列名为<code style='background-color: lightblue;'>lat|latitude和lon|long|longitude</code>。</p><p>
#'      :格式说明: 日期时间格式必须标准化为R惯例,如<b style='text-decoration: underline;'>2023-03-13 11:00:00</b>或<b style='text-decoration: underline;'>2023-03-13</b>。也包括如"1/2/1999"或格式"DD/MM/YYYY","1999-02-01"。</p><p>
#'      :更多信息见: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>示例数据</a> 
#' Variable: 数据框架中目标变量列的名称(如airT, RH, precip)。
#' Station_id: 数据框架中识别气象站的列(如station, site, id)。
#' Date_start: 指定分析开始日期。格式应为<b>DD/MM/YYYY</b>。
#' Date_end: 结束日期,格式与开始日期相同。
#' Select_Anomaly: 如果为TRUE则计算异常。如果为FALSE(默认)则使用原始气温数据。
#' Select_LOOCV: 如果为TRUE(默认)使用留一交叉验证(LOOCV)进行克里金插值。如果为FALSE则使用训练和测试站点的分割方法。
#' SplitRatio: 表示用于训练(插值)的气象站点比例的数值。其余站点将用于测试(评估)。默认值0.8表示80%站点用于训练,20%用于测试。
#' Raster_resolution: 插值的空间分辨率(米)。默认为100。
#' Temporal_resolution: 平均的时间分辨率。默认为"小时"。支持的分辨率:"小时","天","夏令时天","周","月","季度"或"年"。
#' Select_extract_type: 指定用于将LCZ类分配给每个站点的方法。默认为"简单"。可用方法:</p><p>
#'      :1. <b>简单</b>: 根据点所在栅格单元格的值分配LCZ类。常用于低密度观测网络。</p><p>
#'      :2. <b>两步</b>: 在过滤掉位于异质LCZ区域的站点的同时分配LCZ。此方法要求5×5内核中至少80%的像素与中心像素的LCZ匹配(Daniel等,2017)。此方法会减少站点数量。常用于超高密度观测网络。</p><p>
#'      :3. <b>双线性</b>: 从点周围四个最近的栅格单元格插值LCZ类值。</p><p>
#' Viogram_model: 如果选择克里金法,将测试并用克里金法插值的变异函数模型列表。默认为"Sph"。模型有"Sph","Exp","Gau","Ste"(球形、指数、高斯、Matern族、Matern、M.Stein参数化)。
#' Impute_missing_values: 填补缺失值的方法("平均值","中位数","knn","bag")。
#' LCZ_interpolation: 如果为TRUE(默认)使用LCZ插值方法。如果为FALSE则使用不考虑LCZ的传统克里金插值。
#' Output: 文件扩展名:表格(.csv)。示例:<b>/Users/myPC/Documents/lcz_eval.csv</b>
#' ALG_DESC: 此函数评估使用LCZ作为背景的变量(如气温)的空间和时间插值的变异性。支持基于LCZ和传统的插值方法。允许灵活选择时间段、交叉验证以及训练和测试的站点分割。</p><p>
#'         :更多信息请访问: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling_eval.html'>评估基于LCZ的插值</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>  
#' ALG_VERSION: 0.1.0