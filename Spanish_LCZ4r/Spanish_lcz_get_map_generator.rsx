##LCZ4r Funciones Generales=group
##Descargar Mapa LCZ (Plataforma Generadora)display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|ID|ID del LCZ Factsheet|None|optional|true
##QgsProcessingParameterEnum|Select_band_type|Seleccione la característica a utilizar|lczFilter;lcz|-1|0|False
##QgsProcessingParameterRasterDestination|Output|Resultado

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

#' ID: Identificador único generado por la <a href='https://lcz-generator.rub.de/'>Plataforma LCZ Generator</a>.</p><p>Ejemplo (Río de Janeiro): <b>3110e623fbe4e73b1cde55f0e9832c4f5640ac21</b>
#' Output: Archivo raster TIFF (resolución 100 m) con clases LCZ 1-17.
#' ALG_DESC: Recupera mapas de Zonas Climáticas Locales (LCZ) desde la plataforma generadora.</p><p>
#'         :Documentación: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funciones LCZ</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>
#' ALG_VERSION: 0.1.0