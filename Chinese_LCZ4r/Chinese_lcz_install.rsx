##LCZ4r 配置功能=group
##安装LCZ4r=display_name
##pass_filenames
##dont_load_any_packages
##QgsProcessingParameterBoolean|Install|在QGIS中安装LCZ4r|True

if(!require(remotes)) install.packages("remotes")
options(timeout = 300)
remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")

if(!require(interp)) install.packages("interp", type = "binary")
if(!require(SparseM)) install.packages("SparseM", type = "binary")
if(!require(ggiraph)) install.packages("ggiraph", type = "binary")
if(!require(htmlwidgets)) install.packages("htmlwidgets", type = "binary")

#' ALG_DESC: 此功能将安装LCZ4r包及其所有依赖项。</p><p>
#'         : 在进行任何LCZ4r分析前请先运行此脚本。</p><p> 
#'         : 安装过程可能需要几分钟时间。</p><p>
#'         : 如遇问题，请访问: <a href='https://bymaxanjos.github.io/LCZ4r/articles/instalation_lcz4r_qgis.html'>安装指南</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>  
#' ALG_VERSION: 0.1.0
