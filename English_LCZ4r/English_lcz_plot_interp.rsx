##LCZ4r Local Functions=group
##Visualize Interpolated LCZ Map=name
##dont_load_any_packages
##pass_filenames
# ------------------------------
# **1. Input Data**
# ------------------------------
##QgsProcessingParameterRasterLayer|Raster_interpolated|Enter interpolated map|None

# ------------------------------
# **2. Plot Labels and Titles**
# ------------------------------
##QgsProcessingParameterEnum|Palette_color|Palette color|muted;viridi;arid;atlas;bl_yl_rd;deep;gn_yl;high_relieg;pi_y_g;purple;soft|-1|0|False
##QgsProcessingParameterBoolean|display|Visualize plot(.html)|True
##QgsProcessingParameterString|Title|Title|Local Climate Zones|optional|true
##QgsProcessingParameterString|Subtitle|Subtitle|My City|optional|true
##QgsProcessingParameterString|Legend|Legend| AirT[ºC]|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true

# ------------------------------
# **3. Plot Dimensions**
# ------------------------------
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300
#QgsProcessingParameterNumber|Number_of_columns|Number of columns|QgsProcessingParameterNumber.Integer|1
#QgsProcessingParameterNumber|Number_of_rows|Number of rows|QgsProcessingParameterNumber.Integer|1

# ------------------------------
# **4. Output**
# ------------------------------
##QgsProcessingParameterFileDestination|Output|Save your image|PNG Files (*.png)


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
                palette=result_colors
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

#' Raster_interpolated: A <b>SpatRaster</b> from <em>Interpolate LCZ functions</em>
#' Palette_color: Gradient palettes available in the: <a href='https://dieghernan.github.io/tidyterra/articles/palettes.html#scale_fill_whitebox_'>tidyterra package</a> 
#' display: If TRUE, the plot will be displayed in your web browser as an HTML visualization.
#' Output: Specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf).</p><p>
#'       :Example: <b>/Users/myPC/Documents/my_interp_map.png</b>
#' ALG_DESC:This function plots the interpolated LCZ anomaly, LCZ air temperature, or other environmental variables.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>LCZ local functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0