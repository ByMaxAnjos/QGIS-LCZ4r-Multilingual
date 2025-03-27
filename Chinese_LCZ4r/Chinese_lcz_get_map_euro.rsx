##LCZ4r 通用功能=group
##下载 LCZ 地图 (欧洲)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|City|输入城市名称|None|optional|true
##QgsProcessingParameterFeatureSource|ROI|感兴趣区域|2|None|true
##QgsProcessingParameterRasterDestination|Output|输出结果

library(LCZ4r)
library(sf)
library(terra)

if(City != "") {
Output=LCZ4r::lcz_get_map_euro(city=City)
} else { 
Output=LCZ4r::lcz_get_map_euro(city=NULL, roi = ROI)
}

#' City: 基于<a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap项目</a>的目标区域名称字符串。</p><p>示例：<b>里约热内卢</b>（可选）。若为空，将使用自定义ROI。  
#' ROI: 可选参数，可提供ESRI Shapefile或GeoPackage(.gpkg)格式的感兴趣区域(ROI)来裁剪LCZ地图。  
#' Output: 输出分辨率为100米的TIFF栅格文件，包含1-17类LCZ分类。  
#' ALG_DESC: 本功能从全球数据集中获取局部气候分区(LCZ)地图，支持城市或自定义区域（如省、州）范围。</p><p>
#'         :详见：<a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ通用功能文档</a>  
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>  
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r项目</a>  
#' ALG_VERSION: 0.1.0