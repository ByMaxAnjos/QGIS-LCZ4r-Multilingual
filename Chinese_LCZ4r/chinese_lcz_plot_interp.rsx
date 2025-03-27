##LCZ4r 本地函数=group
##可视化插值LCZ地图=name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|Raster_interpolated|输入插值地图|None
##QgsProcessingParameterEnum|Palette_color|颜色调色板|柔和;viridi;干旱;atlas;蓝黄红;深色;绿黄;高浮雕;粉黄绿;紫色;柔和|-1|0|False
##QgsProcessingParameterBoolean|display|可视化图表(.html)|True
##QgsProcessingParameterString|Title|标题|局地气候分区|optional|true
##QgsProcessingParameterString|Subtitle|副标题|我的城市|optional|true
##QgsProcessingParameterString|Legend|图例|气温[°C]|optional|true
##QgsProcessingParameterString|Caption|说明|来源: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|图表高度|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|图表宽度|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|图表分辨率(dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterNumber|Number_of_columns|列数|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterNumber|Number_of_rows|行数|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterFileDestination|Output|保存图像|PNG 文件 (*.png)

library(LCZ4r)
library(ggplot2)
library(terra)
library(ggiraph)
library(htmlwidgets)


#Check color type
colors <- c("muted", "viridi", "arid", "atlas", "bl_yl_rd", "gn_yl", "high_relieg", "pi_y_g", "purple", "soft")
if (!is.null(Palette_color) && Palette_color >= 0 && Palette_color < length(colors)) {
  result_colors <- colors[Palette_color + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_colors <- NULL  # Handle invalid or missing selection
}


plot_map <- lcz_plot_interp(Raster_interpolated, 
                title = Title, 
                subtitle = Subtitle,
                caption = Caption,
                fill = Legend,
                palette=result_colors,
                ncol=Number_of_columns,
                nrow=Number_of_rows
                )
# Plot visualization
if (display) {
        # Save the interactive plot as an HTML file
html_file <- file.path(tempdir(), "LCZ4rPlot.html")
ggiraph::girafe(
  ggobj = plot_map,
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
ggsave(Output, plot_map, height = Height, width = Width, dpi = dpi)

#' Raster_interpolated: 来自<em>LCZ插值函数</em>的<b>SpatRaster</b>对象
#' Palette_color: 可用的渐变色板来自: <a href='https://dieghernan.github.io/tidyterra/articles/palettes.html#scale_fill_whitebox_'>tidyterra包</a> 
#' display: 如为TRUE，图表将在浏览器中以HTML可视化形式显示
#' Output: 指定文件扩展名: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf)</p><p>
#'       :示例: <b>/Users/myPC/Documents/my_interp_map.png</b>
#' ALG_DESC: 本函数绘制插值后的LCZ异常、LCZ气温或其他环境变量</p><p>
#'         :更多信息请访问: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>LCZ局部函数</a> 
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>  
#' ALG_VERSION: 0.1.0