##LCZ4r 通用功能=group
##计算LCZ面积=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|输入LCZ地图|None
##QgsProcessingParameterEnum|Select_plot_type|选择图表类型|柱状图;饼图;环图|-1|0|False
##QgsProcessingParameterBoolean|display|可视化图表(.html)|True
##QgsProcessingParameterString|Title|标题|本地气候分区|optional|true
##QgsProcessingParameterString|Subtitle|副标题|我的城市|optional|true
##QgsProcessingParameterString|Caption|说明|来源: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|xlab|x轴标签|LCZ代码|optional|true
##QgsProcessingParameterString|ylab|y轴标签|面积[平方公里]|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|显示图例|True
##QgsProcessingParameterNumber|Height|图表高度|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|图表宽度|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|图表分辨率(dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|保存为图表|True
##QgsProcessingParameterFileDestination|Output|保存图像|

library(LCZ4r)
library(terra)
library(ggiraph)
library(htmlwidgets)

# Load LCZ raster
LCZ_map <- terra::rast(LCZ_map)

# Check plot type selection
plots <- c("bar", "pie", "donut")
if (!is.null(Select_plot_type) && Select_plot_type >= 0 && Select_plot_type < length(plots)) {
  result_plot <- plots[Select_plot_type + 1] # Align with R's 1-based indexing
} else {
  result_plot <- "bar" # Default plot type if input is invalid
}

# Generate and plot LCZ data
if (Save_as_plot) {
    # Calculate areas and create the plot
    plot_lcz <- LCZ4r::lcz_cal_area(
        LCZ_map, 
        plot_type = result_plot,
        iplot = TRUE, 
        show_legend = Show_LCZ_legend,
        title = Title, 
        subtitle = Subtitle, 
        caption = Caption, 
        xlab = xlab, 
        ylab = ylab
    )

    # Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_lcz,
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

    # Save static plot
    ggplot2::ggsave(Output, plot = plot_lcz, height = Height, width = Width, dpi = dpi)
    
} else {
    # Calculate areas and save as a CSV
    tbl_lcz <- LCZ4r::lcz_cal_area(LCZ_map, iplot = FALSE)
    write.csv(tbl_lcz, Output, row.names = FALSE)
}

#' LCZ_map: 包含LCZ地图的SpatRaster对象（来自 下载LCZ地图 功能）。
#' Select_plot_type: 图表类型。选项: <b>柱状图</b>, <b>饼图</b>, <b>环图</b> </p><p>
#' display: 如果为TRUE，图表将以HTML形式在浏览器中显示。
#' Save_as_plot: 如果为TRUE，保存图表；否则保存数据表(.csv)。输出格式与 Output 关联(.png/.csv)。
#' Show_LCZ_legend: 如果为TRUE，显示LCZ图例。
#' Output: 1. 保存为图表=TRUE 时: 选择文件扩展名(.png, .jpg, .tif, .pdf, .svg)。示例: <b>/Users/我的电脑/文档/lcz面积.png</b>;</p><p>
#'        : 2. 保存为图表=FALSE 时: 保存为表格(.csv)。示例: <b>/Users/我的电脑/文档/lcz面积.csv</b>
#' ALG_DESC: 计算LCZ类别的面积（百分比和平方公里）。</p><p>
#'          : 更多信息: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ4r文档</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>
#' ALG_VERSION: 0.1.0
