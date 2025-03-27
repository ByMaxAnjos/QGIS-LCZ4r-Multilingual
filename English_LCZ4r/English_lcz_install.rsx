##LCZ4r Setup Functions=group
##Install LCZ4r=display_name
##pass_filenames
##QgsProcessingParameterBoolean|Install|Installing the LCZ4r in QGIS|True

remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")
if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")

#' ALG_DESC: This function installs the LCZ4r package and all its dependencies.</p><p>
#'         : Run this script once before performing any LCZ4r analysis.</p><p> 
#'         : The installation process may take a few minutes.</p><p>
#'         : If you experience issues, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Installation Guide</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
