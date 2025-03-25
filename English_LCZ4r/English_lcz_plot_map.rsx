##LCZ4r General Functions=group
##Visualize LCZ Map=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None
##QgsProcessingParameterBoolean|display|Visualize plot(.html)|True
##QgsProcessingParameterString|Title|Title|Local Climate Zones|optional|true
##QgsProcessingParameterString|Subtitle|Subtitle|My City|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Show legend|True
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|inclusive|Inclusive color|False
##QgsProcessingParameterFileDestination|Output|Save your image|PNG Files (*.png)


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

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Obtain LCZ map* functions
#' display: If TRUE, the plot will be displayed in your web browser as an HTML visualization.
#' Show_LCZ_legend: If TRUE, the plot will include the LCZ legend.
#' inclusive: Logical. Set to TRUE to use a colorblind-friendly palette.
#' Output: Specifies file extensions: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       : Example: <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: This function generates a graphical representation of a Local Climate Zone (LCZ) map.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
