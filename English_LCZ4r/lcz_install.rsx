##LCZ4r Setup Functions=group
##Install LCZ4r=display_name
##pass_filenames

# Set the environment variable for standalone mode
Sys.setenv(R_REMOTES_STANDALONE="true")
##ByMaxAnjos/LCZ4r=github_install
##QgsProcessingParameterBoolean|Install|Installing the LCZ4r in QGIS|True

if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")
if(!require(interp)) install.packages("interp", type = "binary")

#' ALG_DESC: This function installs the LCZ4r package and all its required dependencies. Run this script once before performing any LCZ4r analysis. The installation process may take a few minutes, depending on your system and internet connection. Please be patient—your setup will be ready soon!
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
