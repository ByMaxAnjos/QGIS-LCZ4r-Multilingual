##PT-LCZ4r Funções Gerais=group
##Baixar mapa LCZ a partir dos EUA=display_name
##dont_load_any_packages
##pass_filenames
##Cidade=String
##ROI=optional vector
##Saída=output raster
##ByMaxAnjos/LCZ4r=github_install

library(LCZ4r)
library(terra)

Output=lcz_get_map_usa(city=City, roi = ROI)

#' Cidade: Uma string de caracteres especificando o nome da sua área-alvo com base no <a href='https://nominatim.openstreetmap.org/ui/search.html'>projeto OpenStreetMap.</a> 
#' ROI: Opcionalmente, você pode fornecer uma Região de Interesse (ROI) no formato de shapefile ESRI para recortar o mapa LCZ para uma área personalizada.
#' Saída: Um arquivo TIFF raster contendo classes LCZ (resolução de 100 m).
#' DESCR_ALG: Esta função recupera a Zona Climática Local (LCZ) do conjunto de dados de mapeamento global. Ela permite obter o mapa LCZ para uma área específica de interesse, que pode ser uma cidade, estado, região ou forma definida pelo usuário.</p><p>
#'         : Para mais informações, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funções gerais do LCZ</a> 
#' CRIADOR_ALG: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' AJUDA_CRIADOR_ALG: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>projeto LCZ4r</a>  
#' VERSAO_ALG: 0.1.0