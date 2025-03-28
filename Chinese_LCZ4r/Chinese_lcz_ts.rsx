##LCZ4r 局部功能=group
##分析LCZ时间序列 = name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|输入LCZ地图|None
##QgsProcessingParameterFeatureSource|INPUT|输入数据|5
##QgsProcessingParameterField|variable|目标变量列|表格|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|站点标识列|表格|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|开始日期|DD-MM-YYYY|False
##QgsProcessingParameterString|Date_end|结束日期|DD-MM-YYYY|False
##QgsProcessingParameterString|Time_frequency|时间频率|小时|False
##QgsProcessingParameterEnum|Select_extract_type|选择提取方法|简单;两步;双线性|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|数据分组方式|年;季节;季节年;月;月年;工作日;周末;夏令时;小时;日光;日光-月;日光-季节;日光-年|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|缺失值填补|平均值;中位数;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|选择图表类型|基础折线;分面折线;热力图;变暖条纹|-1|0|False
##QgsProcessingParameterEnum|Palette_color|选择颜色调色板|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;埃及;希腊;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronese|-1|0|False
##QgsProcessingParameterBoolean|Smooth_trend_line|平滑趋势线|False
##QgsProcessingParameterString|Title|标题|局地气候分区|optional|true
##QgsProcessingParameterString|xlab|x轴标签|时间|optional|true
##QgsProcessingParameterString|ylab|y轴标签|气温 [°C]|optional|true
##QgsProcessingParameterString|Caption|说明文字|来源: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|图例名称(仅热力图和变暖条纹)|None|optional|true
##QgsProcessingParameterNumber|Height|图表高度(英寸)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|图表宽度(英寸)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|分辨率(DPI)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|display|可视化图表(.html)|True
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
        plot_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
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

        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = my_table, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = Time_frequency,
                         extract.method = result_extract,
                         by = result_by,
                         iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
# Generate data.frame ----

INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

if (Save_as_plot == TRUE) {
        plot_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
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

        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = my_table, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = Time_frequency,
                         extract.method = result_extract,
                         by = result_by,
                         iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
#' LCZ_map: 从<em>下载LCZ地图</em>函数派生的<b>SpatRaster</b>对象。
#' INPUT: 包含环境变量数据的框架(.csv),结构如下:</p><p>
#'      :1. <b>date</b>: 包含日期时间信息的列。确保列名为<code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>station</b>: 指定气象站标识符的列;</p><p>
#'      :3. <b>variable</b>: 表示环境变量(如气温、相对湿度)的列;</p><p>
#'      :4. <b>纬度和经度</b>: 提供数据点地理坐标的两列。确保列名为<code style='background-color: lightblue;'>lat|latitude和lon|long|longitude</code>。</p><p>
#'      :格式说明: 日期时间格式必须标准化为R惯例,如<b style='text-decoration: underline;'>2023-03-13 11:00:00</b>或<b style='text-decoration: underline;'>2023-03-13</b>。也包括如"1/2/1999"或格式"YYYY-mm-dd","1999-02-01"。</p><p>
#'      :更多信息见: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>示例数据</a> 
#' variable: 数据框架中目标变量列的名称(如airT和RH)。
#' station_id: 数据框架中识别气象站的列(如station, site, id)。
#' Date_start: 指定分析开始日期。格式应为<b>DD-MM-YYYY [01-09-1986]</b>。
#' Date_end: 结束日期,格式与开始日期相同。
#' Time_frequency: 定义平均的时间分辨率。默认为"小时"。支持的分辨率包括:"天","周","月"或"年"。自定义选项如"3天","2周"等。
#' Select_extract_type: 指定用于将LCZ类分配给每个站点点的方法。默认为"简单"。可用方法:</p><p>
#'      :1. <b>简单</b>: 根据点所在栅格单元格的值分配LCZ类。常用于低密度观测网络。</p><p>
#'      :2. <b>两步</b>: 在过滤掉位于异质LCZ区域的站点的同时分配LCZ。此方法要求5×5内核中至少80%的像素与中心像素的LCZ匹配(Daniel等,2017)。注意此方法会减少站点数量。常用于超高密度观测网络。</p><p>
#'      :3. <b>双线性</b>: 从点周围四个最近的栅格单元格插值LCZ类值。</p><p>
#' Split_data_by: 确定时间序列的分段方式。选项包括:年、月、日光、夏令时等。组合如日光-月、日光-季节或日光-年(确保时间频率至少为"小时")。</p><p>
#'              :详情访问: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>openair R包中的type参数</a>。
#' Smooth_trend_line: 可选地,使用广义加性模型(GAM)启用平滑趋势线。默认为FALSE。
#' display: 如果为TRUE,图表将在浏览器中以HTML可视化形式显示。
#' Select_plot_type: 选择可视化类型。选项包括:</p><p>
#'      :1. <b>基础折线</b>: 标准折线图</p><p>
#'      :2. <b>分面折线</b>: 按LCZ或站点分面的折线图</p><p>
#'      :3. <b>热力图</b>: 数据的热力图表示</p><p>
#'      :4. <b>变暖条纹</b>: 受气候变暖条纹启发的可视化</p><p>
#' Impute_missing_values: 填补缺失值的方法("平均值","中位数","knn","bag")。
#' Save_as_plot: 选择将输出保存为图表(TRUE)或表格(FALSE)。记得输出(如.jpeg图表和.csv表格)。 
#' Palette_color: 定义图表配色方案。探索<a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>MetBrewer R包</a>中的更多调色板
#' Output:1. 如果保存为图表TRUE,指定文件扩展名:PNG(.png),JPG(.jpg .jpeg),TTIF(.tif),PDF(*.pdf),SVG(*.svg)示例:<b>/Users/myPC/Documents/name_lcz_ts.png</b>;</p><p>
#'       :2. 如果保存为图表FALSE,指定文件扩展名:表格(.csv)。示例:<b>/Users/myPC/Documents/name_lcz_ts.csv</b>
#' ALG_DESC: 此函数支持分析与LCZ相关的气温或其他环境变量随时间的变化。</p><p>
#'         :详细用例和示例参考: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_time_series.html'>LCZ本地函数(时间序列分析)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>  
#' ALG_VERSION: 0.1.0