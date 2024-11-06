##LCZ4r General functions=group
##Download LCZ map from Europe=display_name
##dont_load_any_packages
##pass_filenames
##City=optional String
##ROI=optional vector
##Output=output raster

if (!requireNamespace("remotes", quietly = TRUE)) {
install.packages("remotes") # Install 'remotes' if not already installed
}
remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")
if(!require(data.table)) install.packages("data.table")

library(LCZ4r)
library(terra)
library(sf)


if(City != "") {
Output=lcz_get_map_euro(city=City)
} else { 
Output=lcz_get_map_euro(city=NULL, roi = ROI)
}

# Documentation
#' City: A character string specifying the name of your target european city or area based on the <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap project.</a></p><p> City [opitonal] = <b>Berlin</b>  
#' ROI: Optionally, you can provide a Region of Interest (ROI) in ESRI shapefile format (or .gpkg) to clip the LCZ map to a custom area.
#' Output: A raster TIFF file containing LCZ classes (100 m resolution).
#' ALG_DESC: Obtain your LCZ map from the European LCZ map. It allows you to obtain the LCZ map for a specific area of interest, which can be a city, state, region, or custom-defined shape.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
