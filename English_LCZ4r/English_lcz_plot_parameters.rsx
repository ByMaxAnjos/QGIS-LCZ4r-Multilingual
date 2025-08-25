##LCZ4r General Functions=group
##Visualize LCZ Parameter Map=name 
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map_parameter|Enter LCZ paramter map|None
##QgsProcessingParameterEnum|Select_parameter|Select paramater|SVFmean;SVFmax;SVFmin;z0;ARmean;ARmax;ARmin;BSFmean;BSFmax;BSFmin;ISFmean;ISFmax;ISFmin;PSFmean;PSFmax;PSFmin;TSFmean;TSFmax;TSFmin;HREmean;HREmax;HREmin;TRCmean;TRCmax;TRCmin;SADmean;SADmax;SADmin;SALmean;SALmax;SALmin;AHmean;AHmax;AHmin|-1|0|False
##QgsProcessingParameterBoolean|display|Visualize plot(.html)|True
##QgsProcessingParameterString|Subtitle|Subtitle|My City|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterFileDestination|Output|Save your image|

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

#' LCZ_map_parameter:The SpatRaster in a stack format from Retrieve LCZ parameter function.
#' display: If TRUE, the plot will be displayed in your web browser as an HTML visualization.
#' Select_parameter: Specify one single parameter name based on raster parameter map considering mean, maximum and minumum values:</p><p>
#'             : <b>SVF</b>: Sky View Factor [0-1]. </p><p>
#'             : <b>z0</b>: Roughness Lenght class [meters]. </p><p>
#'             : <b>AR</b>: Aspect Ratio [0-3]. </p><p> 
#'             : <b>BSF</b>: Building Surface Fraction [%]. </p><p> 
#'             : <b>ISF</b>: Impervious Surface Fraction [%]. </p><p>  
#'             : <b>PSF</b>: Pervious Surface Fraction [%]. </p><p>  
#'             : <b>TSF</b>: Tree Surface Fraction [%]. </p><p>  
#'             : <b>HRE</b>: Height Roughness Elements [meters]. </p><p>  
#'             : <b>TRC</b>: Terrain Roughness class [meters]. </p><p>
#'             : <b>SAD</b>: Surface Admittance [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Surface Albedo [0 - 0.5]. </p><p> 
#'             : <b>AH</b>: Anthropogenic Heat Outupt [W m-2]. </p><p> 
#' Output: Specifies file extensions: "png","jpeg", "tiff", "pdf","svg", "eps", "ps", "tex" (pictex), "bmp" or "wmf" (windows).</p><p>
#'       :Example: <b>/Users/myPC/Documents/name_lcz_par.jpeg</b>
#' ALG_DESC: This function generates a graphical representation of a Local Climate Zone (LCZ) map provided as a SpatRaster object.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
