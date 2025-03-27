##LCZ4r Funciones Locales=group
##Analizar Intensidad de Isla de Calor Urbana=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Ingrese mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Datos de entrada|5
##QgsProcessingParameterField|variable|Columna de variable objetivo|Tabla|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Columna de identificación de estaciones|Tabla|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Fecha de inicio|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Fecha de fin|DD-MM-AAAA|False
##QgsProcessingParameterString|Time_frequency|Frecuencia temporal|hora|False
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|media;mediana;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Method|Seleccione método ICU|LCZ;manual|-1|0|False
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|Mostrar estaciones urbanas y rurales|True
##QgsProcessingParameterEnum|Select_extract_type|Método de extracción|simple;dos.pasos;bilineal|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir datos por|año;temporada;temporadaaño;mes;mesaño;día.semana;fin.semana;horario.verano;hora;luz.día;luz.día-mes;luz.día-temporada;luz.día-año|-1|None|True
##QgsProcessingParameterString|Urban_station_reference|Referencia estación urbana|None|optional|true
##QgsProcessingParameterString|Rural_station_reference|Referencia estación rural|None|optional|true
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locales|optional|true
##QgsProcessingParameterString|xlab|Etiqueta eje x|Tiempo|optional|true
##QgsProcessingParameterString|ylab|Etiqueta eje y|Temperatura del Aire [ºC]|optional|true
##QgsProcessingParameterString|ylab2|Etiqueta eje y 2|ICU [ºC]|optional|true
##QgsProcessingParameterString|Caption|Leyenda|Fuente: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Altura (pulgadas)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Ancho (pulgadas)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolución (PPP)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Guardar como gráfico|True
##QgsProcessingParameterFileDestination|Output|Guardar imagen|Archivos PNG (*.png)
library(LCZ4r)
library(sf)
library(ggplot2)
library(terra)
library(lubridate)
library(ggiraph)
library(htmlwidgets)


#Check extract method type
uhi_methods <- c("LCZ", "manual")
if (!is.null(Method) && Method >= 0 && Method < length(uhi_methods)) {
  result_method <- uhi_methods[Method + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_method <- NULL  
}

#Check extract method type
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
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

# Generate data.frame ----

INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

if (Save_as_plot == TRUE) {
        plot_uhi <- lcz_uhi_intensity(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                        start = formatted_start, end = formatted_end,
                        time.freq = Time_frequency, 
                        by = result_by,
                        extract.method = result_extract,
                        method = result_method,
                        Turban= Urban_station_reference,
                        Trural= Rural_station_reference,
                        group = Group_urban_and_rural_temperatures,
                        impute = result_imputes,
                        iplot = TRUE, 
                        title = Title, caption = Caption, xlab = xlab, ylab = ylab, ylab2 = ylab2)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_uhi,
    width_svg = 16,
    height_svg = 9,
    options = list(
    opts_sizing(rescale = TRUE, width = 1),
    opts_tooltip(css = "background-color:white; color:black; font-size:120%; padding:10px;"),
    opts_hover_inv(css = "opacity:0.5;"),
    opts_hover(css = "cursor:pointer; opacity: 0.8;"),
    opts_zoom(min = 0.5, max = 2)
  )
) %>%
  htmlwidgets::saveWidget(
  file = html_file,
  selfcontained = FALSE, # Ensures all dependencies are embedded
  libdir = NULL, # Keep dependencies inline
  title = "LCZ4r Visualization"
)

    # Add caption
    cat('<p style="text-align:right; font-size:16px;">',
    'LCZ4r Project: <a href="https://bymaxanjos.github.io/LCZ4r/index.html" target="_blank">by Max Anjos</a>',
    '</p>', sep = "\n", file = html_file, append = TRUE)

    # Open the HTML file in the default web browser
    utils::browseURL(html_file)
    }
        ggsave(Output, plot_uhi, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_uhi <- lcz_uhi_intensity(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                        time.freq = Time_frequency, 
                        by = result_by,
                        extract.method = result_extract,
                        method = result_method,
                        Turban= Urban_station_reference,
                        Trural= Rural_station_reference,
                        group = Group_urban_and_rural_temperatures,
                        impute = result_imputes, 
                        iplot = FALSE)
        write.csv(tbl_uhi, Output, row.names = FALSE)
    }
#' LCZ_map: Un objeto <b>SpatRaster</b> derivado de las funciones <em>Descargar mapa LCZ</em>.
#' INPUT: Un marco de datos (.csv) con datos de variables ambientales estructurados así:</p><p>
#'      :1. <b>date</b>: Columna con información fecha-hora. Nombre como <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Columna identificando estaciones meteorológicas;</p><p>
#'      :3. <b>Variable</b>: Columna representando la variable ambiental (ej: temperatura del aire, humedad relativa);</p><p>
#'      :4. <b>Latitud y Longitud</b>: Dos columnas con coordenadas geográficas. Nombre como <code style='background-color: lightblue;'>lat|latitude y lon|long|longitude</code>.</p><p>
#'      :Formato fecha-hora: Debe seguir convenciones R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> o <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceptados: "1/2/1999" o "AAAA-MM-DD", "1999-02-01".</p><p>
#'      :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>datos de ejemplo</a> 
#' variable: Nombre de la columna de variable objetivo (ej: airT, HR).
#' station_id: Columna identificando estaciones meteorológicas (ej: station, site, id).
#' Date_start: Fecha de inicio en formato <b>DD-MM-AAAA [01-09-1986]</b>.
#' Date_end: Fecha final en mismo formato.
#' Time_frequency: Resolución temporal para promedio. Por defecto "hora". Opciones: "día", "semana", "mes" o "año". Opciones personalizadas como "3 días", "2 semanas", etc.
#' Impute_missing_values: Método para imputar valores faltantes ("media", "mediana", "knn", "bag").
#' Select_extract_type: Método para asignar clase LCZ a estaciones. Por defecto "simple". Métodos:</p><p>
#'      :1. <b>simple</b>: Asigna clase LCZ basada en valor de celda raster. Usado en redes de baja densidad.</p><p>
#'      :2. <b>dos.pasos</b>: Asigna LCZs filtrando estaciones en áreas heterogéneas. Requiere ≥80% de píxeles coincidentes en kernel 5×5 (Daniel et al., 2017). Reduce número de estaciones. Para redes ultra y alta densidad.</p><p>
#'      :3. <b>bilineal</b>: Interpola valores LCZ de cuatro celdas raster más cercanas.</p><p>
#' Split_data_by: Determina cómo se segmenta la serie temporal. Opciones: año, mes, luz diurna, horario de verano, etc. Combinaciones como luz.día-mes, luz.día-temporada o luz.día-año (frecuencia ≥ "hora").</p><p>
#'              :Detalles: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type en paquete R openair</a>.
#' Method: Método para calcular intensidad ICU. Opciones: "LCZ" y "manual". En "LCZ", la función identifica automáticamente tipos LCZ (LCZ 1-10 para temperatura urbana, LCZ 11-16 para rural).</p><p>
#'       :En "manual", los usuarios seleccionan estaciones de referencia.
#' Urban_station_reference: Con método "manual": seleccione estación urbana de referencia en columna <b>station_id</b>.
#' Rural_station_reference: Con método "manual": seleccione estación rural de referencia en columna <b>station_id</b>.
#' Group_urban_and_rural_temperatures: Si TRUE, agrupa temperaturas urbanas y rurales en mismo gráfico.
#' display: Si TRUE, muestra gráfico en navegador como HTML.
#' Save_as_plot: Si TRUE guarda gráfico, si no dataframe (table.csv). Extensiones: .jpeg para gráficos, .csv para tablas.
#' Output: Si Save as plot TRUE: extensiones PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Ejemplo: <b>/Users/myPC/Documents/lcz_uhi.png</b>;</p><p>
#'       :Si FALSE: tabla (.csv). Ejemplo: <b>/Users/myPC/Documents/lcz_uhi.csv</b>
#' ALG_DESC: Esta función calcula la intensidad de Isla de Calor Urbana (ICU) basada en mediciones de temperatura y Zonas Climáticas Locales (LCZ).</p><p>
#'         :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_uhi.html'>Funciones Locales LCZ (Análisis ICU)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0