##LCZ4r General Functions=group
##Download LCZ map from Generator Platform=display_name
# ------------------------------
# **1. General Settings**
# ------------------------------
##dont_load_any_packages
##pass_filenames
##ByMaxAnjos/LCZ4r=github_install
# ------------------------------
# **2. Input Parameters**
# ------------------------------
##QgsProcessingParameterString|ID|Enter the ID |None|optional|true
##QgsProcessingParameterEnum|Select_band_type|Select the feature to use|lczFilter;lcz|-1|0|False

# ------------------------------
# **3. Output**
# ------------------------------
##QgsProcessingParameterRasterDestination|Output|Save LCZ map


if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets")

library(LCZ4r)
library(sf)
library(terra)

#Check band type
select_band <- c("lczFilter", "lcz")
if (!is.null(Select_band_type) && Select_band_type >= 0 && Select_band_type < length(select_band)) {
  result_band <- select_band[Select_band_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_band <- NULL  
}

Output=LCZ4r::lcz_get_map_generator(ID=ID, band=result_band)


#' ID: A code specifying the ID generated by LCZ Factsheet. More details: <a href='https://lcz-generator.rub.de/'>More details.</a></p><p> Enter the (Rio de Janeiro) ID = <b>3110e623fbe4e73b1cde55f0e9832c4f5640ac21</b>
#' Output: A raster TIFF file with 100 m resolution containing LCZ classes between 1 and 17.
#' ALG_DESC: This function retrieves the Local Climate Zone (LCZ) map from a Generator Platforam dataset.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#download-lcz-map-from-lcz-generator-platform'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
