##LCZ4r 通用功能=group
##下载 LCZ 地图 (生成器平台)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|ID|输入LCZ Factsheet ID|None|optional|true
##QgsProcessingParameterEnum|Select_band_type|选择要使用的特征|lczFilter;lcz|-1|0|False
##QgsProcessingParameterRasterDestination|Output|输出结果

library(LCZ4r)
library(sf)
library(terra)

#Check band type
select_band <- c("lczFilter", "lcz")
if (!is.null(Select_band_type) && Select_band_type >= 0 && Select_band_type < length(select_band)) {
  result_band <- select_band[Select_band_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_band <- NULL  
}

Output=LCZ4r::lcz_get_map_generator(ID=ID, band=result_band)

#' ID: 由<a href='https://lcz-generator.rub.de/'>LCZ生成器平台</a>生成的唯一标识符。</p><p>示例（里约热内卢）：<b>3110e623fbe4e73b1cde55f0e9832c4f5640ac21</b>
#' Output: 100米分辨率的TIFF栅格文件，包含1-17类LCZ分类。
#' ALG_DESC: 从LCZ生成器平台获取局部气候分区(LCZ)地图数据。</p><p>
#'         :详见：<a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ通用功能文档</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>
#' ALG_VERSION: 0.1.0