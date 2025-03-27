##LCZ4r Setup-Funktionen=group
##LCZ4r installieren=display_name
##pass_filenames
##QgsProcessingParameterBoolean|Install|LCZ4r in QGIS installieren|True

remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")
if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")

#' ALG_DESC: Diese Funktion installiert das LCZ4r-Paket und alle Abhängigkeiten.</p><p>
#'         : Führen Sie dieses Skript einmal aus, bevor Sie LCZ4r-Analysen durchführen.</p><p> 
#'         : Der Installationsvorgang kann einige Minuten dauern.</p><p>
#'         : Bei Problemen besuchen Sie: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Installationsanleitung</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r Projekt</a>  
#' ALG_VERSION: 0.1.0
