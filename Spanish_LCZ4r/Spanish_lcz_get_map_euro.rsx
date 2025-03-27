##LCZ4r Funciones Generales=group
##Descargar Mapa LCZ (Europa)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|City|Nombre de la ciudad|None|optional|true
##QgsProcessingParameterFeatureSource|ROI|Área de interés|2|None|true
##QgsProcessingParameterRasterDestination|Output|Resultado

library(LCZ4r)
library(sf)
library(terra)

if(City != "") {
Output=LCZ4r::lcz_get_map_euro(city=City)
} else { 
Output=LCZ4r::lcz_get_map_euro(city=NULL, roi = ROI)
}

#' City: Cadena con el nombre de la ciudad europea (basado en <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap</a>).</p><p>Ejemplo: <b>Berlín</b>. Si está vacío, se usará el ROI personalizado.  
#' ROI: Opcional - proporcione un área de interés (Shapefile/GeoPackage) para recortar el mapa LCZ.  
#' Output: Archivo raster TIFF (resolución 100 m) con clases LCZ 1-17.  
#' ALG_DESC: Descarga mapas LCZ europeos. Soporta ciudades, regiones o áreas personalizadas.</p><p>
#'         :Documentación: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funciones LCZ</a>  
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>  
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0
