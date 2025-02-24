##LCZ4r Local Functions=group
##Visualize interpolated map=name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|Raster_interpolated|Enter interpolated map|None
##QgsProcessingParameterEnum|Palette_color|Palette color|muted;viridi;arid;atlas;bl_yl_rd;deep;gn_yl;high_relieg;pi_y_g;purple;soft|-1|0|False
##QgsProcessingParameterString|Title|Title|LCZ interpolation|optional|true
##QgsProcessingParameterString|Subtitle|Subtitle|My city|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterNumber|Number_of_columns|Number of columns|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterNumber|Number_of_rows|Number of rows|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterFileDestination|Output|Result|PNG Files (*.png)

#Load pacakges
library(LCZ4r)
library(ggplot2)

#Check color type
colors <- c("muted", "viridi", "arid", "atlas", "bl_yl_rd", "gn_yl", "high_relieg", "pi_y_g", "purple", "soft")
if (!is.null(Palette_color) && Palette_color >= 0 && Palette_color < length(colors)) {
  result_colors <- colors[Palette_color + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_colors <- NULL  # Handle invalid or missing selection
}


plot_map <- lcz_plot_interp(Raster_interpolated, 
                title = Title_plot, 
                subtitle = Subtitle,
                caption = Caption,
                fill = Legend,
                palette=result_colors,
                ncol=Number_of_columns,
                nrow=Number_of_rows
                )
ggsave(Output, plot_map, height = Height, width = Width, dpi = dpi)

#' Raster_interpolated: A <b>SpatRaster</b> from <em>Interpolate LCZ functions</em>
#' Palette_color: Gradient palettes available in the: <a href='https://dieghernan.github.io/tidyterra/articles/palettes.html#scale_fill_whitebox_'>tidyterra package</a> 
#' Output: Specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf).</p><p>
#'       :Example: <b>/Users/myPC/Documents/my_interp_map.jpeg</b>
#' ALG_DESC:This function plots the interpolated LCZ anomaly, LCZ air temperature, or other environmental variables.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>LCZ local functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0