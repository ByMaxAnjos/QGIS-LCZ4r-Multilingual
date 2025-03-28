##LCZ4r 通用功能=group
##可视化LCZ参数地图=name 
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map_parameter|输入LCZ参数地图|None
##QgsProcessingParameterEnum|Select_parameter|选择参数|SVFmean;SVFmax;SVFmin;z0;ARmean;ARmax;ARmin;BSFmean;BSFmax;BSFmin;ISFmean;ISFmax;ISFmin;PSFmean;PSFmax;PSFmin;TSFmean;TSFmax;TSFmin;HREmean;HREmax;HREmin;TRCmean;TRCmax;TRCmin;SADmean;SADmax;SADmin;SALmean;SALmax;SALmin;AHmean;AHmax;AHmin|-1|0|False
##QgsProcessingParameterBoolean|display|可视化图表(.html)|True
##QgsProcessingParameterString|Subtitle|副标题|我的城市|optional|true
##QgsProcessingParameterString|Caption|说明文字|来源: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|图表高度|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|图表宽度|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|分辨率(dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterFileDestination|Output|保存图像|PNG文件 (*.png)

library(LCZ4r)
library(ggplot2)
library(terra)
library(ggiraph)
library(htmlwidgets)

# Define the mapping of indices to parameters
parameters <- c("SVFmean", "SVFmax", "SVFmin", 
                "ARmean", "ARmax", "ARmin", 
                "BSFmean", "BSFmax", "BSFmin", 
                "ISFmean", "ISFmax", "ISFmin", 
                "PSFmean", "PSFmax", "PSFmin", 
                "TSFmean", "TSFmax", "TSFmin", 
                "HREmean", "HREmax", "HREmin", 
                "TRCmean", "TRCmax", "TRCmin", 
                "SADmean", "SADmax", "SADmin", 
                "SALmean", "SALmax", "SALmin", 
                "AHmean", "AHmax", "AHmin", 
                "z0")

# Use the selected parameter index to retrieve the corresponding value
# Adjust for zero-based indexing
if (!is.null(Select_parameter) && Select_parameter >= 0 && Select_parameter < length(parameters)) {
  result_par <- parameters[Select_parameter + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_par <- NULL  # Handle invalid or missing selection
}

LCZ_map_parameter <- terra::rast(LCZ_map_parameter)

plot_lcz <- LCZ4r::lcz_plot_parameters(LCZ_map_parameter, iselect = result_par, subtitle=Subtitle, caption = Caption)


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


ggplot2::ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)


#' LCZ_map_parameter: 来自“Retrieve LCZ parameter”函数的堆栈格式 SpatRaster。
#' display: 如果为 TRUE，图表将在浏览器中以 HTML 可视化形式显示。
#' Select_parameter: 根据平均值、最大值或最小值选择一个参数名称：</p><p>
#'             : <b>SVF</b>: 天空可视因子 [0-1]。 </p><p>
#'             : <b>z0</b>: 粗糙度长度 [米]。 </p><p>
#'             : <b>AR</b>: 高宽比 [0-3]。 </p><p> 
#'             : <b>BSF</b>: 建筑表面占比 [%]。 </p><p> 
#'             : <b>ISF</b>: 不透水表面占比 [%]。 </p><p>  
#'             : <b>PSF</b>: 透水表面占比 [%]。 </p><p>  
#'             : <b>TSF</b>: 树木表面占比 [%]。 </p><p>  
#'             : <b>HRE</b>: 粗糙元高度 [米]。 </p><p>  
#'             : <b>TRC</b>: 地形粗糙度等级 [米]。 </p><p>
#'             : <b>SAD</b>: 表面导纳 [J m-2 s1/2 K-1]。 </p><p> 
#'             : <b>SAL</b>: 表面反照率 [0 - 0.5]。 </p><p> 
#'             : <b>AH</b>: 人为热排放 [W m-2]。 </p><p> 
#' Output: 支持的文件格式：PNG (*.png)、JPG (*.jpg *.jpeg)、TIF (*.tif)、PDF (*.pdf)、SVG (*.svg)。</p><p>
#'       :示例：<b>/Users/myPC/Documents/name_lcz_par.jpeg</b>
#' ALG_DESC: 此函数生成以 SpatRaster 对象形式提供的局部气候区 (LCZ) 地图的图形表示。</p><p>
#'         :更多信息：<a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ 通用功能</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r 项目</a>  
#' ALG_VERSION: 0.1.0