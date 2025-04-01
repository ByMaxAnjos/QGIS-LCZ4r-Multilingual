##LCZ4r 通用功能=group
##生成LCZ参数=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|输入 LCZ 地图|None
##QgsProcessingParameterBoolean|iStack|将所有参数保存为一个|True
##QgsProcessingParameterEnum|Select_parameter|SVF均值;SVF最大值;SVF最小值;z0;AR均值;AR最大值;AR最小值;BSF均值;BSF最大值;BSF最小值;ISF均值;ISF最大值;ISF最小值;PSF均值;PSF最大值;PSF最小值;TSF均值;TSF最大值;TSF最小值;HRE均值;HRE最大值;HRE最小值;TRC均值;TRC最大值;TRC最小值;SAD均值;SAD最大值;SAD最小值;SAL均值;SAL最大值;SAL最小值;AH均值;AH最大值;AH最小值|-1|None|True
##QgsProcessingParameterRasterDestination|Output_raster|保存 LCZ 参数

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

#' LCZ_map：一个包含从下载 LCZ 地图函数派生的 LCZ 地图的 SpatRaster 对象。
#' iStack：将多个栅格参数（或波段）保存为一个。
#' Select_parameter：可选，指定一个或多个参数名称以检索特定的均值、最大值和最小值参数值：</p><p>
#'             : <b>SVF</b>：天空视野因子 [0-1]。</p><p>
#'             : <b>z0</b>：粗糙度长度类别 [米]。</p><p>
#'             : <b>AR</b>：纵横比 [0-3]。</p><p> 
#'             : <b>BSF</b>：建筑表面比例 [%]。</p><p> 
#'             : <b>ISF</b>：不透水表面比例 [%]。</p><p>  
#'             : <b>PSF</b>：透水表面比例 [%]。</p><p>  
#'             : <b>TSF</b>：树木表面比例 [%]。</p><p>  
#'             : <b>HRE</b>：高度粗糙度元素 [米]。</p><p>  
#'             : <b>TRC</b>：地形粗糙度类别 [米]。</p><p>
#'             : <b>SAD</b>：表面透过率 [J m-2 s1/2 K-1]。</p><p> 
#'             : <b>SAL</b>：表面反照率 [0 - 0.5]。</p><p> 
#'             : <b>AH</b>：人类热输出 [W m-2]。</p><p> 
#' Output_raster：1. 如果 <b>将所有参数保存为一个</b> 为 TRUE，则返回所有参数作为栅格堆叠（100 米分辨率）。</p><p>
#'              : 2. 如果 <b>将所有参数保存为一个</b> 为 FALSE，则返回所选参数作为单个栅格（100 米分辨率）。
#' ALG_DESC：此函数根据 Stewart 和 Oke（2012）开发的分类方案提取 12 个 LCZ 物理城市冠层参数（UCP）。
#'         :有关更多信息，请访问：<a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#retrieve-and-visualize-lcz-parameters'>LCZ 一般功能（检索和可视化 LCZ 参数）</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r 项目</a>
#' ALG_VERSION: 0.1.0