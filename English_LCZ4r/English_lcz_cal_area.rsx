##LCZ4r General Functions=group
##Calculate LCZ Areas=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None
##QgsProcessingParameterEnum|Select_plot_type|Select plot type|bar;pie;donut|-1|0|False
##QgsProcessingParameterBoolean|display|Visualize plot(.html)|True
##QgsProcessingParameterString|Title|Title|Local Climate Zones|optional|true
##QgsProcessingParameterString|Subtitle|Subtitle|My City|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|xlab|xlab|LCZ code|optional|true
##QgsProcessingParameterString|ylab|ylab|Area [square kilometers]|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Show legend|True
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Save as plot|True
##QgsProcessingParameterFileDestination|Output|Save your image|

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


#' LCZ_map: A SpatRaster object containing the LCZ map derived from Download LCZ map* functions.
#' Select_plot_type: Choose the visualization type. Options include: <b>bar</b>, <b>pie</b>,<b>donut</b> </p><p>
#' display: If TRUE, the plot will be displayed in your web browser as an HTML visualization.
#' Save_as_plot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs (.jpeg for plot and .csv for table). 
#' Show_LCZ_legend: If TRUE, the plot will include the LCZ legend.
#' Output:1. If Save as plot is TRUE, specifies file extension: "png","jpeg", "tiff", "pdf","svg", "eps", "ps", "tex" (pictex), "bmp" or "wmf" (windows). Example: <b>/Users/myPC/Documents/name_lcz_area.png</b>;</p><p>
#'       :2. if Save as plot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/name_lcz_area.csv</b>
#' ALG_DESC: This functon calculates the areas of LCZ classes in both percentage and square kilometers.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
