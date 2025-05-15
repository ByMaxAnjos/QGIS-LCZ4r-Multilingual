##LCZ4r Funções Locais=group
##Gerar Mapa Interpolado de Anomalia LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Dados de entrada|5
##QgsProcessingParameterField|variable|Selecione a variável a ser interpolada|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Selecione o ID das Estações|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Data de início|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Data de término|DD-MM-AAAA|False
##QgsProcessingParameterString|Select_hour|Especificar um horário|0:23|optional|True
##QgsProcessingParameterEnum|Temporal_resolution|Resolução temporal|Horária;Diária;Semanal;Mensal;Sazonal;Trimestral;Anual|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Resolução raster|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Modelo de variograma|Esf;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Selecione o método de extração|Simples;Duas Etapas;Bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir dados por|Ano;Estação;Estação por Ano;Mês;Meses por Ano;Dia Útil;Fim de Semana;Hora;Ciclo Diurno;Ciclo Diurno por Mês;Ciclo Diurno por Estação;Ciclo Diurno por Ano|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Preencher valores faltantes|Média;Mediana;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|Interpolação LCZ-Krigagem|True
##QgsProcessingParameterRasterDestination|Output|Salvar seu mapa

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

# Check for date conditions by
type_by <- c("year","season", "seasonyear", "month", "monthyear","weekday", "weekend", "dst", "hour", "daylight", "daylight-month", "daylight-season", "daylight-year")
if (!is.null(Split_data_by) && Split_data_by >= 0 && Split_data_by < length(type_by)) {
  result_by <- type_by[Split_data_by + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_by <- NULL  # Handle invalid or missing selection
}

if ("daylight-month" %in% result_by) {
    result_by <- c("daylight", "month")
}
if ("daylight-season" %in% result_by) {
    result_by <- c("daylight", "season")
}
if ("daylight-year" %in% result_by) {
    result_by <- c("daylight", "year")
}

# Generate and plot or data.frame ----
INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

# Check if Hour is an empty string and handle accordingly
if(Select_hour != "") { 
   # Check if Hour contains a colon and split accordingly
    if (grepl(":", Select_hour)) { 
  # Directly convert to numeric range
    Select_hour <- as.numeric(unlist(strsplit(Select_hour, ":")))  # Split and convert to numeric
    Select_hour <- Select_hour[1]:Select_hour[2]  # Create a range from start to end hour
    } else if (grepl(",", Select_hour)) {
    Select_hour <- as.numeric(unlist(strsplit(gsub("c\\(|\\)", "", Select_hour), ",")))
    } else {
    Select_hour <- as.numeric(Select_hour)  # Convert to numeric if not a range
    }
    if (LCZ_interpolation) {
        Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
         Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
} else {
    if (LCZ_interpolation){
          Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
          Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
}
 
#' LCZ_map: Um objeto em formato <b>SpatRaster</b> derivado das funções <em>"Baixar Mapa LCZ"</em>.
#' INPUT: Uma tabela (.csv), contendo dados de variáveis ambientais estruturados assim:</p><p>
#'      :1. <b>Data</b>: Coluna com informações de data-hora. Nomeie a coluna como <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Estação</b>: Coluna com identificadores de estações meteorológicas;</p><p>
#'      :3. <b>Variável</b>: Coluna representando a variável a ser interpolada (ex: temperatura do ar, umidade relativa);</p><p>
#'      :4. <b>Latitude e Longitude</b>: Duas colunas com coordenadas geográficas. Nomeie como <code style='background-color: lightblue;'>lat|latitude e lon|long|longitude</code>.</p><p>
#'      :Nota de formatação: Formate data-hora conforme convenções R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceitos: "1/2/1999" ou "DD/MM/AAAA", "1999-02-01".</p><p>
#'      :Para mais informações, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>dados de exemplo</a>.
#' variable: Selecione a coluna da variável a ser interpolada (ex: airT, RH, precip).
#' station_id: Selecione a coluna que identifica estações meteorológicas (ex: estações, site, id).
#' Date_start: Data de início no formato <b>DD/MM/AAAA</b>. Ex.: 01-09-1986.
#' Date_end: Data final, mesmo formato que Data de Início.
#' Select_hour: Especifique hora(s) de 0 a 23. Formatos:</p><p>
#'      :Intervalo: 0:12 seleciona horas 0 a 12;</p><p>
#'      :Horas específicas: c(1,6,18,21) seleciona horas 1,6,18 e 21;</p><p>
#'      :Deixe vazio para dados diários/mensais/anuais.
#' Raster_resolution: Resolução espacial em metros para interpolação. Padrão: 100.
#' Temporal_resolution: Define a resolução temporal para os quais dados são arredondados. O padrão é "Horária". Resoluções suportadas incluem: Horária, Diária, Semanal, Mensal, Sazonal, Trimestral ou Anual.
#' Select_extract_type: Método de atribuição de classes LCZ. Padrão: "simples". Métodos:</p><p>
#'      :1. <b>Simples</b>: Atribui classe LCZ baseada no valor da célula raster. Usado em redes de baixa densidade.</p><p>
#'      :2. <b>Duas Etapas</b>: Filtra estações em áreas LCZ heterogêneas. Requer ≥80% de pixels concordantes em kernel 5×5 (Daniel et al., 2017). Reduz número de estações.</p><p>
#'      :3. <b>Bilinear</b>: Interpola valores LCZ das 4 células raster mais próximas.</p><p>
#' Split_data_by: Segmentação da série temporal. Opções: Ano, Mês, Ciclo Diurno, etc. "Ciclo Diurno" divide dados em períodos diurnos/noturnos.</p><p>
#'              :Combinações: Ciclo Diurno por Mês, Ciclo Diurno por Estação ou Ciclo Diurno por Ano ("Time_resolution" deve ser "Hora").</p><p>
#'              :Para mais detalhes, visite: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type no pacote R openair</a>.
#' Viogram_model: Se a krigagem estiver selecionada, exibe lista de modelos de variograma testados. Padrão: "Esf". </p><p> Modelos: "Esf" (esférico), "Exp" (exponencial), "Gau" (gaussiano), "Ste" (família Matern, parametrização de Stein).
#' Impute_missing_values: Método para preencher valores faltantes ("Média", "Mediana", "knn", "bag").
#' LCZ_interpolation: Se estiver selecionada (padrão), usa abordagem LCZ. Se não estiver, realiza interpolação convencional sem LCZ.
#' Output: Um arquivo raster no formato GeoTIF da Terra.
#' ALG_DESC: Esta função gera uma representação gráfica de anomalias térmicas para diferentes Zonas Climáticas Locais (LCZs).</p><p>
#'         :Para mais informações, visite:: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling.html#interpolating-thermal-anomalies-with-lcz'>Funções Locais LCZ (Interpolação de anomalias térmicas com LCZ)</a>.
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a>.
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>.
#' ALG_VERSION: 0.1.0