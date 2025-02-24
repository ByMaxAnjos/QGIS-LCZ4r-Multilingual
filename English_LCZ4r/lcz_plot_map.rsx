##LCZ4r General Functions=group
##Visualize LCZ Map=display_name
##dont_load_any_packages
##pass_filenames

# ------------------------------
# **1. Input Data**
# ------------------------------
##QgsProcessingParameterRasterLayer|LCZ_map|Enter LCZ map|None

# ------------------------------
# **2. Plot Labels and Titles**
# ------------------------------
##QgsProcessingParameterString|Title|Title|Local Climate Zones|optional|true
##QgsProcessingParameterString|Subtitle|Subtitle|My City|optional|true
##QgsProcessingParameterString|Caption|Caption|Source: LCZ4r, 2024.|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Show legend|True

# ------------------------------
# **3. Plot Dimensions**
# ------------------------------
##QgsProcessingParameterNumber|Height|Height plot|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Width plot|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|dpi plot resolution|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|inclusive|Inclusive color|False

# ------------------------------
# **4. Output**
# ------------------------------
##QgsProcessingParameterFileDestination|Output|Result|PNG Files (*.png)


library(LCZ4r)
library(ggplot2)

# Generate and plot the LCZ map
plot_lcz<-lcz_plot_map(LCZ_map, 
            show_legend=Show_LCZ_legend,
            title = Title, 
            subtitle=Subtitle, 
            caption = Caption, 
            inclusive=inclusive)
ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Obtain LCZ map* functions
#' Show_LCZ_legend: If TRUE, the plot will include the LCZ legend.
#' inclusive: Logical. Set to TRUE to use a colorblind-friendly palette.
#' Output: Specifies file extensions: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       : Example: <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: This function generates a graphical representation of a Local Climate Zone (LCZ) map.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
