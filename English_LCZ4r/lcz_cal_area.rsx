##LCZ4r General Functions=group
##Calculate LCZ Areas=display_name
##pass_filenames
# ------------------------------
# **1. Input Data**
# ------------------------------
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None

# ------------------------------
# **2. Plot Labels and Titles**
# ------------------------------
##QgsProcessingParameterEnum|Select_plot_type|Select plot type|bar;pie;donut|-1|0|False
##QgsProcessingParameterString|Title|Title|Local Climate Zones|optional|true
##QgsProcessingParameterString|Subtitle|Subtitle|My City|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|xlab|xlab|LCZ code|optional|true
##QgsProcessingParameterString|ylab|ylab|Area [square kilometer]|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Show legend|True

# ------------------------------
# **3. Plot Dimensions**
# ------------------------------
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300

# ------------------------------
# **4. Output**
# ------------------------------
##QgsProcessingParameterBoolean|Save_as_plot|Save as plot|True
##QgsProcessingParameterFileDestination|Output|Result|PNG Files (*.png)

library(LCZ4r)
library(ggplot2)

# Generate and plot LCZ data
if (Save_as_plot) {
    # Calculate areas and create the plot
    plot_lcz <- lcz_cal_area(
        LCZ_map, 
        plot_type=Select_plot_type,
        iplot = TRUE, 
        show_legend = Show_LCZ_legend,
        title = Title, 
        subtitle = Subtitle, 
        caption = Caption, 
        xlab = xlab, 
        ylab = ylab
    )
    # Save the plot with the specified DPI and dimensions
    ggsave(Output, plot = plot_lcz, height = Height, width = Width, dpi = dpi)
} else {
    # Calculate areas and output as a data frame
    tbl_lcz <- lcz_cal_area(LCZ_map, iplot = FALSE)
    write.csv(tbl_lcz, Output, row.names = FALSE)
}

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Download LCZ map* functions
#' Select_plot_type: Choose the visualization type. Options include: <b>bar</b>, <b>pie</b>,<b>donut</b> </p><p>
#' Save_as_plot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs (.jpeg for plot and .csv for table). 
#' Show_LCZ_legend: If TRUE, the plot will include the LCZ legend.
#' Output:1. If Save_as_plot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf), SVG (*.svg) Example: <b>/Users/myPC/Documents/name_lcz_area.jpeg</b>;</p><p>
#'       :2. if Save_as_plot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/name_lcz_area.csv</b>
#' ALG_DESC: This function calculates the areas of LCZ classes in both percentage and square kilometers.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
