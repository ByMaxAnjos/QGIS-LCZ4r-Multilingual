##LCZ4r Funções de Configuração=group
##Instalar LCZ4r=display_name
##pass_filenames
##QgsProcessingParameterBoolean|Install|Instalando o LCZ4r no QGIS|True

if(!require(remotes)) install.packages("remotes")
remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")

if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")

#' ALG_DESC: Esta função instala o pacote LCZ4r e todas suas dependências.</p><p>
#'         : Execute este script uma vez antes de realizar qualquer análise LCZ4r.</p><p> 
#'         : O processo de instalação pode levar alguns minutos.</p><p>
#'         : Se encontrar problemas, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Guia de Instalação</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0