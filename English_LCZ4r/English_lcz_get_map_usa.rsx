##LCZ4r General Functions=group
##Download LCZ map (USA)=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterString|City|Enter the city name|None|optional|true
##QgsProcessingParameterFeatureSource|ROI|Region of Interest (ROI)|2|None|true
##QgsProcessingParameterRasterDestination|Output|Save LCZ Map

library(LCZ4r)
library(sf)
library(terra)

if(City != "") {
Output=LCZ4r::lcz_get_map_usa(city=City)
} else { 
Output=LCZ4r::lcz_get_map_usa(city=NULL, roi = ROI)
}

#' City: A character string specifying the name of your target Continental United States city or area based on the <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap project.</a></p><p> Enter the city name = <b>Chicago</b></p><p> If left empty,  the function uses the custom ROI.  
#' ROI: Optionally, you can provide a Region of Interest (ROI) in ESRI shapefile format (or .gpkg) to clip the LCZ map to a custom area.
#' Output: A raster TIFF file with 100 m resolution containing LCZ classes between 1 and 17.
#' ALG_DESC: Obtain your LCZ map from the Continental United States LCZ dataset. It allows you to obtain the LCZ map for a specific area of interest, which can be a city, state, region, or custom-defined shape.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
