##LCZ4r Fonctions de configuration=group
##Installer LCZ4r=display_name
##pass_filenames
##QgsProcessingParameterBoolean|Install|Installation de LCZ4r dans QGIS|True

if(!require(remotes)) install.packages("remotes")
remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")

if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")

#' ALG_DESC: Cette fonction installe le package LCZ4r et toutes ses dépendances.</p><p>
#'         : Exécutez ce script une fois avant toute analyse LCZ4r.</p><p> 
#'         : Le processus d'installation peut prendre quelques minutes.</p><p>
#'         : En cas de problème, consultez : <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Guide d'installation</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0
