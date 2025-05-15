##LCZ4r Funções Gerais=group
##Gerar Parâmetros LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Inserir mapa LCZ|None
##QgsProcessingParameterBoolean|iStack|Salvar todos os parâmetros como um único|True
##QgsProcessingParameterEnum|Select_parameter|Selecione um parâmetro|SVFmédia;SVFmax;SVFmin;z0;ARmédia;ARmax;ARmin;BSFmédia;BSFmax;BSFmin;ISFmédia;ISFmax;ISFmin;PSFmédia;PSFmax;PSFmin;TSFmédia;TSFmax;TSFmin;HREmédia;HREmax;HREmin;TRCmédia;TRCmax;TRCmin;SADmédia;SADmax;SADmin;SALmédia;SALmax;SALmin;AHmédia;AHmax;AHmin|-1|None|True
##QgsProcessingParameterRasterDestination|Output_raster|Salvar parâmetro LCZ

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

#' LCZ_map: Um objeto em formato SpatRaster que contém o mapa LCZ (gerado pelo conjunto de funções "Baixar Mapa LCZ").
#' iStack: Salvar múltiplos parâmetros em arquivo no formato raster (ou bandas) como um único.
#' Select_parameter: Opcionalmente, especifique um ou mais nomes de parâmetros para recuperar valores específicos de média, máximo e mínimo:</p><p>
#'             : <b>SVF</b>: Fator de Visão do Céu [0-1]. </p><p>
#'             : <b>z0</b>: Classe de Comprimento de Rugosidade [metros]. </p><p>
#'             : <b>AR</b>: Razão de Aspecto [0-3]. </p><p> 
#'             : <b>BSF</b>: Fração de Superfície de Edifícios [%]. </p><p> 
#'             : <b>ISF</b>: Fração de Superfície Impermeável [%]. </p><p>  
#'             : <b>PSF</b>: Fração de Superfície Permeável [%]. </p><p>  
#'             : <b>TSF</b>: Fração de Superfície de Árvores [%]. </p><p>  
#'             : <b>HRE</b>: Elementos de Rugosidade de Altura [metros]. </p><p>  
#'             : <b>TRC</b>: Classe de Rugosidade do Terreno [metros]. </p><p>
#'             : <b>SAD</b>: Admitância de Superfície [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Albedo de Superfície [0 - 0.5]. </p><p> 
#'             : <b>AH</b>: Saída de Calor Antropogênico [W m-2]. </p><p> 
#' Output_raster: 1. Se a opção <b>"Salvar todos os parâmetros como um único"</b> estiver selecionada, retorna todos os parâmetros como um empilhamento no formato raster (resolução de 100 m). </p><p>
#'              : 2. Se a opção <b>"Salvar todos os parâmetros como um único"</b> não estiver selecionada, retorna o parâmetro selecionado como um único raster (resolução de 100 m).
#' ALG_DESC: Esta função extrai 12 parâmetros físicos da cobertura urbana LCZ (UCP) com base no esquema de classificação desenvolvido por Stewart e Oke (2012). 
#'         :Para mais informações, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#retrieve-and-visualize-lcz-parameters'>Funções Gerais LCZ (Gerar e Visualizar paramêtros LCZ)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a> 