##LCZ4r General functions=group
##Download LCZ map from global=display_name
##dont_load_any_packages
##pass_filenames
##City=optional String
##ROI=optional vector
##Output=output raster

if(!require(LCZ4r)) remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")
if(!require(LCZ4r)) install.packages("data.table")

library(LCZ4r)
library(terra)
library(sf)

if(City != "") {
Output=lcz_get_map(city=City)
} else { 
Output=lcz_get_map(city=NULL, roi = ROI)
}


#' City: A character string specifying the name of your target area based on the <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap project.</a></p><p> City [opitonal] = <b>Rio de Janeiro</b>.</p><p> If left empty,  the function uses the custom ROI.  
#' ROI: Optionally, provide a Region of Interest (ROI) in ESRI Shapefile or GeoPackage (.gpkg) format to clip the LCZ map to a specific area.
#' Output: A raster TIFF file containing LCZ classes (100 m resolution). The output will be saved as a raster in your specified location.
#' ALG_DESC: This function retrieves the Local Climate Zone (LCZ) map from a global dataset. It allows you to obtain the LCZ map for a city or a custom-defined region (state, region).</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
