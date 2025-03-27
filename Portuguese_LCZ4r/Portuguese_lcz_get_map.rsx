##LCZ4r Funções Gerais=group
##Baixar Mapa LCZ (Global)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|City|Nome da cidade|None|optional|true
##QgsProcessingParameterFeatureSource|ROI|Área de interesse|2|None|true
##QgsProcessingParameterRasterDestination|Output|Resultado

library(LCZ4r)
library(terra)
library(sf)

if(City != "") {
Output=lcz_get_map(city=City)
} else { 
Output=lcz_get_map(city=NULL, roi = ROI)
}


#' City: Nome da cidade ou região alvo baseado em <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap</a>.</p><p>Exemplo: <b>Rio de Janeiro</b>. Se vazio, usa ROI personalizada.
#' ROI: Opcional - forneça uma área de interesse (Shapefile/GeoPackage) para recortar o mapa LCZ.
#' Output: Arquivo raster TIFF (100 m de resolução) com classes LCZ 1-17.
#' ALG_DESC: Baixa mapas LCZ do banco de dados global. Suporta cidades ou regiões personalizadas.</p><p>
#'         :Documentação: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funções LCZ</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>
#' ALG_VERSION: 0.1.0