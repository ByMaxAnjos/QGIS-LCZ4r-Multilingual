##LCZ4r 通用功能=group
##可视化LCZ地图=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|输入LCZ地图|None
##QgsProcessingParameterBoolean|display|可视化图表(.html)|True
##QgsProcessingParameterString|Title|标题|局部气候分区|optional|true
##QgsProcessingParameterString|Subtitle|副标题|我的城市|optional|true
##QgsProcessingParameterString|Caption|说明文字|来源: LCZ4r, 2024.|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|显示图例|True
##QgsProcessingParameterNumber|Height|图表高度|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|图表宽度|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|分辨率(dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|inclusive|包容性配色|False
##QgsProcessingParameterFileDestination|Output|保存图像|PNG文件 (*.png)


library(LCZ4r)
library(ggplot2)
library(terra)
library(ggiraph)
library(htmlwidgets)

LCZ_map <- terra::rast(LCZ_map)

# Generate and plot the LCZ map
plot_lcz<-LCZ4r::lcz_plot_map(LCZ_map, 
            show_legend=Show_LCZ_legend,
            title = Title, 
            subtitle=Subtitle, 
            caption = Caption, 
            inclusive=inclusive)
 # Plot visualization
if (display) {
        # Save the interactive plot as an HTML file
html_file <- file.path(tempdir(), "LCZ4rPlot.html")
ggiraph::girafe(
  ggobj = plot_lcz,
  width_svg = 14,
  height_svg = 9,
  options = list(
    opts_sizing(rescale = TRUE, width = 1),
       opts_tooltip(css = "background-color: white; color: black; 
                     font-size: 14px; padding: 10px; border-radius: 5px;"),
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

#' LCZ_map: 包含LCZ地图的SpatRaster对象（来自*Obtain LCZ map*函数）
#' display: 如果为TRUE，图表将在浏览器中以HTML格式显示。
#' Show_LCZ_legend: 如果为TRUE，图表将包含LCZ图例。
#' inclusive: 逻辑值。设为TRUE可使用色盲友好配色。
#' Output: 支持的文件格式: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg)。</p><p>
#'       : 示例: <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: 此函数生成局部气候分区(LCZ)地图的图形表示。</p><p>
#'         : 更多信息: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ通用功能</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>  
#' ALG_VERSION: 0.1.0
