##LCZ4r Funciones Locales=group
##Mapa de Temperatura del Aire LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Ingrese mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Datos de entrada|5
##QgsProcessingParameterField|variable|Columna de variable objetivo|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Columna de identificación de estaciones|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Fecha de inicio|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Fecha de fin|DD-MM-AAAA|False
##QgsProcessingParameterString|Select_hour|Especificar hora|0:23|optional|True
##QgsProcessingParameterEnum|Temporal_resolution|Resolución temporal|hora;día;díaDST;semana;mes;temporada;trimestre;año|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Resolución raster|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Modelo de variograma|Esf;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Seleccionar método de extracción|simple;dos.pasos;bilineal|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir datos por|año;temporada;temporadaAño;mes;mesAño;díaSemana;finSemana;dst;hora;luzDía;luzDía-mes;luzDía-temporada;luzDía-año|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|media;mediana;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|Interpolación LCZ-kriging|True
##QgsProcessingParameterRasterDestination|Output|Guardar mapa

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
        Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
         Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
          Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
          Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
}
 
#' LCZ_map: Un objeto <b>SpatRaster</b> derivado de las funciones <em>Descargar mapa LCZ</em>.
#' INPUT: Un dataframe (.csv) con datos de variables ambientales estructurados así:</p><p>
#'      :1. <b>date</b>: Columna con información fecha-hora. Nombre la columna <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Columna con identificadores de estaciones meteorológicas;</p><p>
#'      :3. <b>Variable</b>: Columna que representa la variable ambiental (ej: temperatura del aire, humedad relativa);</p><p>
#'      :4. <b>Latitud y Longitud</b>: Dos columnas con coordenadas geográficas. Nombre las columnas <code style='background-color: lightblue;'>lat|latitude y lon|long|longitude</code>.</p><p>
#'      :Nota de formato: El formato fecha-hora debe seguir convenciones R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> o <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceptados: "1/2/1999" o "AAAA-MM-DD", "1999-02-01".</p><p>
#'      :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>datos de ejemplo</a>.
#' Variable: Nombre de la columna de la variable objetivo (ej: airT, RH, precip).
#' Station_id: Columna que identifica estaciones meteorológicas (ej: station, site, id).
#' Date_start: Fecha de inicio en formato <b>DD-MM-AAAA [01-09-1986]</b>.
#' Date_end: Fecha final, mismo formato que Date_start.
#' Select_hour: Especifique hora(s) de 0 a 23. Formatos:</p><p>
#'      :Rango: 0:12 selecciona horas 0 a 12;</p><p>
#'      :Horas específicas: c(1,6,18,21) selecciona horas 1,6,18 y 21;</p><p>
#'      :Para datos diarios/mensuales/anuales, dejar vacío.
#' Raster_resolution: Resolución espacial en metros para interpolación. Por defecto: 100.
#' Temporal_resolution: Resolución temporal para promediar. Por defecto: "hora". Opciones: "hora", "día", "díaDST", "semana", "mes", "trimestre" o "año".
#' Select_extract_type: Método para asignar clases LCZ. Por defecto: "simple". Métodos:</p><p>
#'      :1. <b>simple</b>: Asigna clase LCZ según valor de celda raster. Usado en redes de baja densidad.</p><p>
#'      :2. <b>dos.pasos</b>: Filtra estaciones en áreas LCZ heterogéneas. Requiere ≥80% de píxeles concordantes en kernel 5×5 (Daniel et al., 2017). Reduce número de estaciones. Para redes ultra-densas.</p><p>
#'      :3. <b>bilineal</b>: Interpola valores LCZ de las 4 celdas raster más cercanas.</p><p>
#' Split_data_by: Segmentación de series temporales. Opciones: año, mes, luz diurna, dst (horario de verano), wd (dirección del viento) etc. "luz diurna" divide datos en períodos diurnos/nocturnos.</p><p>
#'              :Combinaciones: luz diurna-mes, luz diurna-estación o luz diurna-año (Time_resolution debe ser "hora").</p><p>
#'              :Detalles: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type en paquete R openair</a>.
#' Viogram_model: Si se selecciona kriging, lista de modelos de variograma a probar. Por defecto: "Esf". Modelos: "Esf" (esférico), "Exp" (exponencial), "Gau" (gaussiano), "Ste" (familia Matern, parametrización de Stein).
#' Impute_missing_values: Método para imputar valores faltantes ("media", "mediana", "knn", "bag").
#' LCZ_interpolation: Si TRUE (por defecto), usa enfoque LCZ. Si FALSE, kriging convencional sin LCZ.
#' Output: Raster en formato GeoTIF de terra.
#' ALG_DESC: Esta función genera interpolación espacial de temperatura (u otra variable) usando LCZ y kriging.</p><p>
#'         :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling.html'>Funciones Locales LCZ (Modelado de Temperatura con LCZ)</a>.
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a>.
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>.
#' ALG_VERSION: 0.1.0