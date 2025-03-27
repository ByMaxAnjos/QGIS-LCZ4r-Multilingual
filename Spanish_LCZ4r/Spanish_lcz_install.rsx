##LCZ4r Funciones de Configuración=group
##Instalar LCZ4r=display_name
##pass_filenames
##QgsProcessingParameterBoolean|Install|Instalando LCZ4r en QGIS|True

remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")
if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")

#' ALG_DESC: Esta función instala el paquete LCZ4r y todas sus dependencias.</p><p>
#'         : Ejecute este script una vez antes de realizar cualquier análisis LCZ4r.</p><p> 
#'         : El proceso de instalación puede tardar unos minutos.</p><p>
#'         : Si experimenta problemas, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Guía de Instalación</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0