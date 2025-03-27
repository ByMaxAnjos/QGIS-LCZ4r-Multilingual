##LCZ4r Funciones Locales=group
##Evaluar Interpolación LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Ingrese mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Datos de entrada|5
##QgsProcessingParameterField|variable|Columna de variable objetivo|Tabla|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Columna de identificación de estaciones|Tabla|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Fecha de inicio|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Fecha de fin|DD-MM-AAAA|False
##QgsProcessingParameterBoolean|Select_Anomaly|Evaluar anomalía|FALSE
##QgsProcessingParameterBoolean|Select_LOOCV|LOOCV (validación cruzada leave-one-out)|True
##QgsProcessingParameterNumber|SplitRatio|Proporción estación entrenamiento/prueba (si LOOCV falso)|QgsProcessingParameterNumber.Double|0.8
##QgsProcessingParameterEnum|Temporal_resolution|Resolución temporal|hora;día;día.verano;semana;mes;temporada;trimestre;año|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Resolución raster|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Modelo de variograma|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Seleccione método de extracción|simple;dos.pasos;bilineal|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|media;mediana;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|Interpolación LCZ-kriging|True
##QgsProcessingParameterFileDestination|Output|Guardar tabla|Archivos (*.csv)


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
 
#' LCZ_map: Un objeto <b>SpatRaster</b> derivado de las funciones <em>Descargar mapa LCZ</em>.
#' INPUT: Un marco de datos (.csv) con datos de variables ambientales estructurados así:</p><p>
#'      :1. <b>date</b>: Columna con información fecha-hora. Nombre como <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Columna identificando estaciones meteorológicas;</p><p>
#'      :3. <b>Variable</b>: Columna representando la variable ambiental (ej: temperatura del aire, humedad relativa, precipitación);</p><p>
#'      :4. <b>Latitud y Longitud</b>: Dos columnas con coordenadas geográficas. Nombre como <code style='background-color: lightblue;'>lat|latitude y lon|long|longitude</code>.</p><p>
#'      :Formato fecha-hora: Debe seguir convenciones R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> o <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceptados: "1/2/1999" o "DD/MM/AAAA", "1999-02-01".</p><p>
#'      :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>datos de ejemplo</a> 
#' Variable: Nombre de la columna de variable objetivo (ej: airT, RH, precip).
#' Station_id: Columna identificando estaciones meteorológicas (ej: station, site, id).
#' Date_start: Fecha de inicio en formato <b>DD/MM/AAAA</b>.
#' Date_end: Fecha final en mismo formato.
#' Select_Anomaly: Si TRUE, calcula anomalías. Si FALSE (predeterminado), usa temperaturas brutas.
#' Select_LOOCV: Si TRUE (predeterminado), usa validación cruzada leave-one-out (LOOCV) para kriging. Si FALSE, usa método de división en estaciones de entrenamiento y prueba.
#' SplitRatio: Valor numérico representando proporción de estaciones para entrenamiento (interpolación). El resto será para pruebas (evaluación). Predeterminado 0.8 significa 80% para entrenamiento y 20% para pruebas.
#' Raster_resolution: Resolución espacial en metros para interpolación. Predeterminado 100.
#' Temporal_resolution: Resolución temporal para promedio. Predeterminado "hora". Opciones: "hora", "día", "día.verano", "semana", "mes", "trimestre" o "año".
#' Select_extract_type: Método para asignar clase LCZ a estaciones. Predeterminado "simple". Métodos:</p><p>
#'      :1. <b>simple</b>: Asigna clase LCZ basada en valor de celda raster. Usado en redes de baja densidad.</p><p>
#'      :2. <b>dos.pasos</b>: Asigna LCZs filtrando estaciones en áreas heterogéneas. Requiere ≥80% de píxeles coincidentes en kernel 5×5 (Daniel et al., 2017). Reduce número de estaciones. Para redes ultra y alta densidad.</p><p>
#'      :3. <b>bilineal</b>: Interpola valores LCZ de cuatro celdas raster más cercanas.</p><p>
#' Viogram_model: Si kriging seleccionado, lista de modelos de variograma a probar. Predeterminado "Sph". Modelos: "Sph", "Exp", "Gau", "Ste" (esférico, exponencial, gaussiano, familia Matern, Matern, parametrización M. Stein).
#' Impute_missing_values: Método para imputar valores faltantes ("media", "mediana", "knn", "bag").
#' LCZ_interpolation: Si TRUE (predeterminado), usa enfoque de interpolación LCZ. Si FALSE, usa kriging convencional sin LCZ.
#' Output: Extensión de archivo: tabla (.csv). Ejemplo: <b>/Users/myPC/Documents/lcz_eval.csv</b>
#' ALG_DESC: Esta función evalúa variabilidad de interpolación espacial y temporal de variable (ej: temperatura) usando LCZ como fondo. Soporta métodos de interpolación basados en LCZ y convencionales. Permite selección flexible de período, validación cruzada y división de estaciones para entrenamiento y pruebas.</p><p>
#'         :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling_eval.html'>Evaluando Interpolación Basada en LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0