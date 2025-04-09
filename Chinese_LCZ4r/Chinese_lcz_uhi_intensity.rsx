##LCZ4r 局部功能=group
##分析城市热岛强度=display_name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|输入LCZ地图|None
##QgsProcessingParameterFeatureSource|INPUT|输入数据|5
##QgsProcessingParameterField|variable|目标变量列|表格|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|站点标识列|表格|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|开始日期|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|结束日期|DD-MM-YYYY|False
##QgsProcessingParameterEnum|Time_frequency|时间频率|小时;天;夏令时天;周;月;季节;季度;年|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|缺失值填补|平均值;中位数;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Method|选择UHI方法|LCZ;手动|-1|0|False
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|显示城乡站点|True
##QgsProcessingParameterEnum|Select_extract_type|选择提取方法|简单;两步;双线性|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|数据分组方式|年;季节;季节年;月;月年;工作日;周末;夏令时;小时;日光;日光-月;日光-季节;日光-年|-1|None|True
##QgsProcessingParameterString|Urban_station_reference|城市站点参考|None|optional|true
##QgsProcessingParameterString|Rural_station_reference|乡村站点参考|None|optional|true
##QgsProcessingParameterBoolean|display|可视化图表(.html)|True
##QgsProcessingParameterString|Title|标题|局地气候分区|optional|true
##QgsProcessingParameterString|xlab|x轴标签|时间|optional|true
##QgsProcessingParameterString|ylab|y轴标签|气温 [°C]|optional|true
##QgsProcessingParameterString|ylab2|y轴标签2|热岛强度 [°C]|optional|true
##QgsProcessingParameterString|Caption|说明文字|来源: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|图表高度(英寸)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|图表宽度(英寸)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|分辨率(DPI)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|保存为图表|True
##QgsProcessingParameterFileDestination|Output|保存图像|PNG文件 (*.png)
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
                        time.freq = result_time, 
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
                        time.freq = result_time, 
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

#' LCZ_map: 从<em>下载LCZ地图</em>函数派生的<b>SpatRaster</b>对象。
#' INPUT: 包含环境变量数据的框架(.csv),结构如下:</p><p>
#'      :1. <b>date</b>: 包含日期时间信息的列。确保列名为<code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: 指定气象站标识符的列;</p><p>
#'      :3. <b>Variable</b>: 表示环境变量(如气温、相对湿度)的列;</p><p>
#'      :4. <b>纬度和经度</b>: 提供数据点地理坐标的两列。确保列名为<code style='background-color: lightblue;'>lat|latitude和lon|long|longitude</code>。</p><p>
#'      :格式说明: 日期时间格式必须标准化为R惯例,如<b style='text-decoration: underline;'>2023-03-13 11:00:00</b>或<b style='text-decoration: underline;'>2023-03-13</b>。也包括如"1/2/1999"或格式"YYYY-mm-dd","1999-02-01"。</p><p>
#'      :更多信息见: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>示例数据</a> 
#' variable: 数据框架中目标变量列的名称(如airT, HR)。
#' station_id: 数据框架中识别气象站的列(如station, site, id)。
#' Date_start: 指定分析开始日期。格式应为<b>DD-MM-YYYY [01-09-1986]</b>。
#' Date_end: 结束日期,格式与开始日期相同。
#' Time_frequency: 定义用于计算平均值的时间分辨率。默认为小时。支持的分辨率包括：小时、天、夏令时天、周、月、季度以及年。
#' Impute_missing_values: 填补缺失值的方法("平均值","中位数","knn","bag")。
#' Select_extract_type: 指定用于将LCZ类分配给每个站点的方法。默认为"简单"。可用方法:</p><p>
#'      :1. <b>简单</b>: 根据点所在栅格单元格的值分配LCZ类。常用于低密度观测网络。</p><p>
#'      :2. <b>两步</b>: 在过滤掉位于异质LCZ区域的站点的同时分配LCZ。此方法要求5×5内核中至少80%的像素与中心像素的LCZ匹配(Daniel等,2017)。此方法会减少站点数量。常用于超高密度观测网络。</p><p>
#'      :3. <b>双线性</b>: 从点周围四个最近的栅格单元格插值LCZ类值。</p><p>
#' Split_data_by: 确定时间序列的分段方式。选项包括:年、月、日光、夏令时等。组合如日光-月、日光-季节或日光-年(确保时间频率至少为"小时")。</p><p>
#'              :详情访问: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>openair R包中的type参数</a>。
#' Method: 计算UHI强度的方法。选项包括"LCZ"和"手动"。在LCZ方法中,函数自动识别LCZ建筑类型(LCZ 1-10表示城市温度,LCZ 11-16表示农村温度)。</p><p>
#'       :在手动方法中,用户可自由选择站点作为城乡参考。
#' Urban_station_reference: 如果选择"手动"方法,在<b>station_id</b>列中选择城市参考站。
#' Rural_station_reference: 如果选择"手动"方法,在<b>station_id</b>列中选择农村参考站。
#' Group_urban_and_rural_temperatures: 如果为TRUE,城乡气温将在同一图表中分组显示。
#' display: 如果为TRUE,图表将在浏览器中以HTML可视化形式显示。
#' Save_as_plot: 设置为TRUE将图表保存为图像,否则保存为数据框架(table.csv)。输出文件:.jpeg图表和.csv表格。
#' Output: 如果保存为图表TRUE,指定文件扩展名:PNG(.png),JPG(.jpg .jpeg),TIF(.tif),PDF(*.pdf)。示例:<b>/Users/myPC/Documents/lcz_uhi.png</b>;</p><p>
#'       :如果为FALSE,指定文件扩展名:表格(.csv)。示例:<b>/Users/myPC/Documents/lcz_uhi.csv</b>
#' ALG_DESC: 此函数基于气温测量和局地气候分区(LCZ)计算城市热岛(UHI)强度。</p><p>
#'         :更多信息请访问: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_uhi.html'>LCZ本地函数(城市热岛分析)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>  
#' ALG_VERSION: 0.1.0