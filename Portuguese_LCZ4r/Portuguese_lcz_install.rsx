##LCZ4r Funções de Configuração=group
##Instalar LCZ4r=display_name
##pass_filenames
##dont_load_any_packages
##QgsProcessingParameterBoolean|Install|Instalar o LCZ4r no QGIS|True

if(!require(remotes)) install.packages("remotes")
remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")

if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")

#' ALG_DESC: Esta função instala o pacote LCZ4r e todas as suas dependências.</p><p>
#'         : Execute esta função uma vez antes de realizar qualquer análise com o pacote LCZ4r.</p><p> 
#'         : O processo de instalação pode levar alguns minutos para garantir que todas as dependências necessárias sejam instaladas.</p><p>
#'         : Se encontrar problemas ou tiver dúvidas sobre a instalação, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>Guia de Instalação</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0