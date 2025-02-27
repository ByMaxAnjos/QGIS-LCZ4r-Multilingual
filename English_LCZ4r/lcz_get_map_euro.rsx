##LCZ4r General Functions=group
##Download LCZ map from Europe=display_name
# ------------------------------
# **1. General Settings**
# ------------------------------
##dont_load_any_packages
##pass_filenames

# ------------------------------
# **2. Input Parameters**
# ------------------------------
##QgsProcessingParameterString|City|Enter the city name |None|optional|true
##QgsProcessingParameterFeatureSource|ROI|ROI|2|None|true

# ------------------------------
# **3. Output**
# ------------------------------
##QgsProcessingParameterRasterDestination|Output|Result

if (!requireNamespace("remotes", quietly = TRUE)) {install.packages("remotes")}
if(!require(LCZ4r)) remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")

library(LCZ4r)
library(terra)
library(sf)


if(City != "") {
Output=lcz_get_map_euro(city=City)
} else { 
Output=lcz_get_map_euro(city=NULL, roi = ROI)
}

# Documentation
#' City: A character string specifying the name of your target european city or area based on the <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap project.</a></p><p> Enter the city name [opitonal] = <b>Berlin</b>  
#' ROI: Optionally, you can provide a Region of Interest (ROI) in ESRI shapefile format (or .gpkg) to clip the LCZ map to a custom area.
#' Output: A raster TIFF file with 100 m resolution containing LCZ classes between 1 and 17.
#' ALG_DESC: Obtain your LCZ map from the European LCZ map. It allows you to obtain the LCZ map for a specific area of interest, which can be a city, state, region, or custom-defined shape.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
