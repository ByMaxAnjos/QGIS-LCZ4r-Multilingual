##LCZ4r Funciones Generales=group
##Generar Parámetros LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Ingresar mapa LCZ|None
##QgsProcessingParameterBoolean|iStack|Guardar todos los parámetros como uno solo|True
##QgsProcessingParameterEnum|Select_parameter|Seleccionar parámetro|SVFmín;SVFmax;SVFmin;z0;ARmín;ARmax;ARmin;BSFmín;BSFmax;BSFmin;ISFmín;ISFmax;ISFmin;PSFmín;PSFmax;PSFmin;TSFmín;TSFmax;TSFmin;HREmín;HREmax;HREmin;TRCmín;TRCmax;TRCmin;SADmín;SADmax;SADmin;SALmín;SALmax;SALmin;AHmín;AHmax;AHmin|-1|None|True
##QgsProcessingParameterRasterDestination|Output_raster|Guardar parámetro LCZ

library(LCZ4r)
library(terra)


# Define the mapping of indices to parameters
parameters <- c("SVFmean", "SVFmax", "SVFmin", 
                "ARmean", "ARmax", "ARmin", 
                "BSFmean", "BSFmax", "BSFmin", 
                "ISFmean", "ISFmax", "ISFmin", 
                "PSFmean", "PSFmax", "PSFmin", 
                "TSFmean", "TSFmax", "TSFmin", 
                "HREmean", "HREmax", "HREmin", 
                "TRCmean", "TRCmax", "TRCmin", 
                "SADmean", "SADmax", "SADmin", 
                "SALmean", "SALmax", "SALmin", 
                "AHmean", "AHmax", "AHmin", 
                "z0")

# Use the selected parameter index to retrieve the corresponding value
# Adjust for zero-based indexing
if (!is.null(Select_parameter) && Select_parameter >= 0 && Select_parameter < length(parameters)) {
  result_par <- parameters[Select_parameter + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_par <- NULL  # Handle invalid or missing selection
}

# Retrieve the LCZ parameters based on user input
if (iStack==TRUE) {
  Output_raster <- LCZ4r::lcz_get_parameters(LCZ_map, iselect = " ", istack = iStack)
} else {
 Output_raster <- LCZ4r::lcz_get_parameters(LCZ_map, iselect = result_par,istack = FALSE)
} 

#' LCZ_map: Un objeto SpatRaster que contiene el mapa LCZ derivado de las funciones de descarga del mapa LCZ.
#' iStack: Guardar múltiples parámetros raster (o bandas) como uno solo.
#' Select_parameter: Opcionalmente, especificar uno o más nombres de parámetros para recuperar valores específicos de media, máximo y mínimo:</p><p>
#'             : <b>SVF</b>: Factor de Vista del Cielo [0-1]. </p><p>
#'             : <b>z0</b>: Clase de Longitud de Rugosidad [metros]. </p><p>
#'             : <b>AR</b>: Relación de Aspecto [0-3]. </p><p> 
#'             : <b>BSF</b>: Fracción de Superficie de Edificios [%]. </p><p> 
#'             : <b>ISF</b>: Fracción de Superficie Impermeable [%]. </p><p>  
#'             : <b>PSF</b>: Fracción de Superficie Permeable [%]. </p><p>  
#'             : <b>TSF</b>: Fracción de Superficie de Árboles [%]. </p><p>  
#'             : <b>HRE</b>: Elementos de Rugosidad de Altura [metros]. </p><p>  
#'             : <b>TRC</b>: Clase de Rugosidad del Terreno [metros]. </p><p>
#'             : <b>SAD</b>: Admitancia de Superficie [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Albedo de Superficie [0 - 0.5]. </p><p> 
#'             : <b>AH</b>: Salida de Calor Antropogénico [W m-2]. </p><p> 
#' Output_raster: 1. Si <b>Guardar todos los parámetros como uno solo</b> es TRUE, devuelve todos los parámetros como un apilamiento raster (resolución de 100 m). </p><p>
#'              : 2. Si <b>Guardar todos los parámetros como uno solo</b> es FALSE, devuelve el parámetro seleccionado como un solo raster (resolución de 100 m).
#' ALG_DESC: Esta función extrae 12 parámetros físicos de la cubierta urbana LCZ (UCP) basados en el esquema de clasificación desarrollado por Stewart y Oke (2012). 
#'         :Para más información, visita: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#retrieve-and-visualize-lcz-parameters'>Funciones Generales de LCZ (Recuperar y visualizar parámetros LCZ)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0