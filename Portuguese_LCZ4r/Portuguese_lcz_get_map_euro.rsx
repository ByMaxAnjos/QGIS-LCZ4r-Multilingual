##LCZ4r Funções Gerais=group
##Baixar Mapa LCZ (Europa)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|City|Nome da cidade|None|optional|true
##QgsProcessingParameterFeatureSource|ROI|Área de interesse|2|None|true
##QgsProcessingParameterRasterDestination|Output|Resultado

library(LCZ4r)
library(sf)
library(terra)

if(City != "") {
Output=LCZ4r::lcz_get_map_euro(city=City)
} else { 
Output=LCZ4r::lcz_get_map_euro(city=NULL, roi = ROI)
}

#' City: Uma variável textual do tipo "String", com o nome da cidade europeia (baseado em <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap</a>).</p><p>Exemplo: <b>Berlim</b>. Se o parâmetro estiver vazio, usa uma Região de Interesse (ROI) personalizada.  
#' ROI: Opcional - forneça uma área de interesse (Shapefile/GeoPackage) para gerar o recorte do mapa LCZ.
#' Output: Arquivo raster no formato .TIFF (100 m de resolução) contendo as classes LCZ 1-17 
#' ALG_DESC: Baixa mapas LCZ europeus. A função suporta cidades, regiões ou áreas personalizadas.</p><p>
#'         :Documentação: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funções LCZ</a>  
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>  
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0
