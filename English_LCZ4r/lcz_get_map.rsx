##LCZ4r General Functions=group
##Download LCZ map from Global=display_name
# ------------------------------
# **1. General Settings**
# ------------------------------
##dont_load_any_packages
##pass_filenames
##ByMaxAnjos/LCZ4r=github_install
# ------------------------------
# **2. Input Parameters**
# ------------------------------
##QgsProcessingParameterString|City|Enter the city name |None|optional|true
##QgsProcessingParameterFeatureSource|ROI|ROI|2|None|true

# ------------------------------
# **3. Output**
# ------------------------------
##QgsProcessingParameterRasterDestination|Output|Save LCZ Map

if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets")

library(LCZ4r)
library(terra)
library(sf)

if(City != "") {
Output=lcz_get_map(city=City)
} else { 
Output=lcz_get_map(city=NULL, roi = ROI)
}


#' City: A character string specifying the name of your target area based on the <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap project.</a></p><p> Enter the city name [opitonal] = <b>Rio de Janeiro</b>.</p><p> If left empty,  the function uses the custom ROI.  
#' ROI: Optionally, provide a Region of Interest (ROI) in ESRI Shapefile or GeoPackage (.gpkg) format to clip the LCZ map to a specific area.
#' Output: A raster TIFF file with 100 m resolution containing LCZ classes between 1 and 17.
#' ALG_DESC: This function retrieves the Local Climate Zone (LCZ) map from a global dataset. It allows you to obtain the LCZ map for a city or a custom-defined region (state, region).</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
