##LCZ4r Funções Locais=group
##Avaliar Interpolação LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Dados de entrada|5
##QgsProcessingParameterField|variable|Coluna da variável alvo|Tabela|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Coluna de identificação das estações|Tabela|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Data inicial|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Data final|DD-MM-AAAA|False
##QgsProcessingParameterBoolean|Select_Anomaly|Avaliar anomalia|FALSE
##QgsProcessingParameterBoolean|Select_LOOCV|LOOCV (validação cruzada leave-one-out)|True
##QgsProcessingParameterNumber|SplitRatio|Proporção estações treino/teste (se LOOCV falso)|QgsProcessingParameterNumber.Double|0.8
##QgsProcessingParameterEnum|Temporal_resolution|Resolução temporal|hora;dia;dia.verão;semana;mês;estação;trimestre;ano|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Resolução raster|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Modelo de variograma|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Selecione o método de extração|simples;dois.passos;bilinear|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|média;mediana;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|Interpolação LCZ-krigagem|True
##QgsProcessingParameterFileDestination|Output|Salvar sua tabela|Arquivos (*.csv)


library(LCZ4r)
library(ggplot2)
library(terra)
library(lubridate)


#Check extract method type
time_options <- c("hour", "day", "DSTday", "week", "month", "season", "quater", "year")
if (!is.null(Temporal_resolution) && Temporal_resolution >= 0 && Temporal_resolution < length(time_options)) {
  result_time <- time_options[Temporal_resolution + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_time <- NULL  
}


#Check extract method type
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
}

#Check method type
methods <- c("Sph", "Exp", "Gau", "Ste")
if (!is.null(Viogram_model) && Viogram_model >= 0 && Viogram_model < length(methods)) {
  result_methods <- methods[Viogram_model + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_methods <- NULL  # Handle invalid or missing selection
}

#Check impute missing values
imputes <- c("mean", "median", "knn", "bag")
if (!is.null(Impute_missing_values) && Impute_missing_values >= 0 && Impute_missing_values < length(imputes)) {
  result_imputes <- imputes[Impute_missing_values + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_imputes <- NULL  # Handle invalid or missing selection
}


# Generate and plot or data.frame ----
INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

# Check if Hour is an empty string and handle accordingly
    if (LCZ_interpolation) {
        eval_lcz=lcz_interp_eval(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          LOOCV = Select_LOOCV,
                          split.ratio = SplitRatio,
                          Anomaly = Select_Anomaly,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          #by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    write.csv(eval_lcz, Output, row.names = FALSE)
    } else {
         Output=lcz_interp_eval(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          LOOCV = Select_LOOCV,
                          split.ratio = SplitRatio,
                          Anomaly = Select_Anomaly,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          #by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    write.csv(eval_lcz, Output, row.names = FALSE)
    }
 
#' LCZ_map: Um objeto <b>SpatRaster</b> derivado das funções <em>Baixar mapa LCZ</em>.
#' INPUT: Um dataframe (.csv) contendo dados de variáveis ambientais estruturados assim:</p><p>
#'      :1. <b>date</b>: Coluna com informações data-hora. Nomeie como <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Coluna identificando estações meteorológicas;</p><p>
#'      :3. <b>Variable</b>: Coluna representando a variável ambiental (ex: temperatura do ar, umidade relativa, precipitação);</p><p>
#'      :4. <b>Latitude e Longitude</b>: Duas colunas com coordenadas geográficas. Nomeie como <code style='background-color: lightblue;'>lat|latitude e lon|long|longitude</code>.</p><p>
#'      :Formato data-hora: Deve seguir convenções R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceitos: "1/2/1999" ou "DD/MM/AAAA", "1999-02-01".</p><p>
#'      :Mais informações: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>dados de exemplo</a> 
#' Variable: Nome da coluna da variável alvo (ex: airT, RH, precip).
#' Station_id: Coluna identificando estações meteorológicas (ex: station, site, id).
#' Date_start: Data de início no formato <b>DD/MM/AAAA</b>.
#' Date_end: Data final no mesmo formato.
#' Select_Anomaly: Se TRUE, calcula anomalias. Se FALSE (padrão), usa temperaturas brutas.
#' Select_LOOCV: Se TRUE (padrão), usa validação cruzada leave-one-out (LOOCV) para krigagem. Se FALSE, usa método de divisão em estações de treino e teste.
#' SplitRatio: Valor numérico representando proporção de estações para treino (interpolação). O restante será para teste (avaliação). Padrão 0.8 significa 80% para treino e 20% para teste.
#' Raster_resolution: Resolução espacial em metros para interpolação. Padrão 100.
#' Temporal_resolution: Resolução temporal para média. Padrão "hora". Opções: "hora", "dia", "dia.verão", "semana", "mês", "trimestre" ou "ano".
#' Select_extract_type: Método para atribuir classe LCZ a estações. Padrão "simples". Métodos:</p><p>
#'      :1. <b>simples</b>: Atribui classe LCZ baseada no valor da célula raster. Usado em redes de baixa densidade.</p><p>
#'      :2. <b>dois.passos</b>: Atribui LCZs filtrando estações em áreas heterogêneas. Requer ≥80% de pixels correspondentes em kernel 5×5 (Daniel et al., 2017). Reduz número de estações. Para redes ultra e alta densidade.</p><p>
#'      :3. <b>bilinear</b>: Interpola valores LCZ das quatro células raster mais próximas.</p><p>
#' Viogram_model: Se krigagem selecionada, lista de modelos de variograma para testar. Padrão "Sph". Modelos: "Sph", "Exp", "Gau", "Ste" (esférico, exponencial, gaussiano, família Matern, Matern, parametrização M. Stein).
#' Impute_missing_values: Método para imputar valores faltantes ("média", "mediana", "knn", "bag").
#' LCZ_interpolation: Se TRUE (padrão), usa abordagem de interpolação LCZ. Se FALSE, usa krigagem convencional sem LCZ.
#' Output: Extensão de arquivo: tabela (.csv). Exemplo: <b>/Users/myPC/Documents/lcz_eval.csv</b>
#' ALG_DESC: Esta função avalia a variabilidade de uma interpolação espacial e temporal de uma variável (ex: temperatura) usando LCZ como fundo. Suporta métodos de interpolação baseados em LCZ e convencionais. Permite seleção flexível de período, validação cruzada e divisão de estações para treino e teste.</p><p>
#'         :Mais informações: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling_eval.html'>Avaliando Interpolação Baseada em LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0