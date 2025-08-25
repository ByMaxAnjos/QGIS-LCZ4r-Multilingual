##LCZ4r Funciones Locales=group
##Calcular Anomalías LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Ingrese mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Datos de entrada|5
##QgsProcessingParameterField|variable|Columna de variable objetivo|Tabla|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Columna de identificación de estaciones|Tabla|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Fecha de inicio|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Fecha de fin|DD-MM-AAAA|False
##QgsProcessingParameterEnum|Time_frequency|Frecuencia temporal|hora;día;día.verano;semana;mes;temporada;trimestre;año|-1|0|False
##QgsProcessingParameterString|Select_hour|Especificar una hora|0:23|optional|True
##QgsProcessingParameterEnum|Select_extract_type|Seleccione método de extracción|simple;dos.pasos;bilineal|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir datos por|año;temporada;temporadaaño;mes;mesaño;día.semana;fin.semana;horario.verano;hora;luz.día;luz.día-mes;luz.día-temporada;luz.día-año|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|media;mediana;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|Seleccione tipo de gráfico|barras_divergentes;barras;puntos;lollipop|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Elija paleta de colores|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Egipto;Griego;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronés|-1|0|False
##QgsProcessingParameterString|Title|Título|Anomalías LCZ|optional|true
##QgsProcessingParameterString|xlab|Etiqueta eje x|Estaciones|optional|true
##QgsProcessingParameterString|ylab|Etiqueta eje y|Temperatura del Aire [ºC]|optional|true
##QgsProcessingParameterString|Caption|Leyenda|Fuente: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Nombre de leyenda|Anomalía [ºC]|optional|true
##QgsProcessingParameterNumber|Height|Altura del gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Ancho del gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolución del gráfico (PPP)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterBoolean|Save_as_plot|Guardar como gráfico|True
##QgsProcessingParameterFileDestination|Output|Guardar imagen|

library(LCZ4r)
library(sf)
library(ggplot2)
library(terra)
library(lubridate)
library(ggiraph)
library(htmlwidgets)

#Check extract method type
time_options <- c("hour", "day", "DSTday", "week", "month", "season", "quater", "year")
if (!is.null(Time_frequency) && Time_frequency >= 0 && Time_frequency < length(time_options)) {
  result_time <- time_options[Time_frequency + 1]  # Add 1 to align with R's 1-based indexing
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


#Check plot type
plots <- c("diverging_bar", "bar", "dot", "lollipop")
if (!is.null(Select_plot_type) && Select_plot_type >= 0 && Select_plot_type < length(plots)) {
  result_plot <- plots[Select_plot_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_plot <- NULL  # Handle invalid or missing selection
}

#Check color type
colors <- c("VanGogh2", "Archambault", "Cassatt1", "Cassatt2", "Demuth", "Derain", "Egypt", "Greek", "Hiroshige", "Hokusai2", "Hokusai3", "Ingres", "Isfahan1", "Isfahan2", "Java", "Johnson", "Kandinsky", "Morgenstern", "OKeeffe2", "Pillement", "Tam", "Troy", "VanGogh3", "Veronese")
if (!is.null(Palette_color) && Palette_color >= 0 && Palette_color < length(colors)) {
  result_colors <- colors[Palette_color + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_colors <- NULL  # Handle invalid or missing selection
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

    if (grepl(":", Select_hour)) { 
  # Directly convert to numeric range
    Select_hour <- as.numeric(unlist(strsplit(Select_hour, ":")))  # Split and convert to numeric
    Select_hour <- Select_hour[1]:Select_hour[2]  # Create a range from start to end hour
    } else if (grepl(",", Select_hour)) {
    Select_hour <- as.numeric(unlist(strsplit(gsub("c\\(|\\)", "", Select_hour), ",")))
    } else {
    Select_hour <- as.numeric(Select_hour)  # Convert to numeric if not a range
    }
    if (Save_as_plot==TRUE) {
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          time.freq = result_time, 
                          extract.method = result_extract,
                          by = result_by,
                          plot_type=result_plot,
                          impute= result_imputes,
                          legend_name=Legend_name,
                          palette = result_colors,
                          iplot = TRUE, title = Title, caption = Caption, xlab = xlab, ylab = ylab)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
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
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end, hour=Select_hour,
                         time.freq = result_time,
                         extract.method = result_extract,
                         by = result_by,
                         impute = Impute_missing_values, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
} else {
    if (Save_as_plot==TRUE){
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          time.freq = result_time, 
                          extract.method = result_extract,
                          by = result_by,
                          plot_type=result_plot,
                          impute= result_imputes,
                          legend_name=Legend_name,
                          palette = result_colors,
                          iplot = TRUE, title = Title, caption = Caption, xlab = xlab, ylab = ylab)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
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
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = result_time,
                         extract.method = result_extract,
                         by = result_by,
                         impute = result_imputes, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
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
#' Time_frequency: Define la resolución temporal para promediar. Por defecto hora. Resoluciones soportadas: hora, día, día_de_verano, semana, mes, trimestre y año.
#' Select_extract_type: Método para asignar clase LCZ a estaciones. Por defecto "simple". Métodos:</p><p>
#'      :1. <b>simple</b>: Asigna clase LCZ basada en valor de celda raster. Usado en redes de baja densidad.</p><p>
#'      :2. <b>dos.pasos</b>: Asigna LCZs filtrando estaciones en áreas heterogéneas. Requiere ≥80% de píxeles coincidentes en kernel 5×5 (Daniel et al., 2017). Reduce número de estaciones. Para redes ultra y alta densidad.</p><p>
#'      :3. <b>bilineal</b>: Interpola valores LCZ de cuatro celdas raster más cercanas.</p><p>
#' Split_data_by: Determina cómo se segmenta la serie temporal. Opciones: año, mes, luz diurna, horario de verano, etc. Combinaciones como luz.día-mes, luz.día-temporada o luz.día-año (resolución ≥ "hora").</p><p>
#'              :Detalles: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type en paquete R openair</a>.
#' Select_hour: Especificar hora o rango de horas de 0 a 23. Formatos posibles:</p><p>
#'      :Rango: 0:12 selecciona horas 0 a 12 inclusive;</p><p>
#'      :Conjunto específico: c(1, 6, 18, 21) selecciona horas 1, 6, 18 y 21;</p><p>
#'      :Para datos diarios, mensuales o anuales, dejar este parámetro vacío.
#' Select_plot_type: Elija entre:</p><p>
#'      :1. <b>barras_divergentes</b>: Gráfico de barras horizontales divergentes desde el centro (cero), anomalías positivas a derecha y negativas a izquierda. Ideal para mostrar extensión y dirección de anomalías;</p><p>
#'      :2. <b>barras</b>: Gráfico de barras mostrando magnitud de anomalías por estación, coloreadas por positivas/negativas. Bueno para comparar anomalías entre estaciones;</p><p>
#'      :3. <b>puntos</b>: Gráfico de puntos mostrando valores medios y de referencia, conectados por líneas. Tamaño/color de puntos indica magnitud de anomalía. Ideal para valores absolutos y anomalías;</p><p>
#'      :4. <b>lollipop</b>: Gráfico lollipop donde cada "palito" representa valor de anomalía y puntos en topo su tamaño. Visualización clara de anomalías positivas/negativas.</p><p>
#' Impute_missing_values: Método para imputar valores faltantes: "media", "mediana", "knn", "bag".
#' display: Si TRUE, muestra gráfico en navegador como HTML.
#' Save_as_plot: Si TRUE guarda gráfico, si no dataframe (table.csv). Extensiones: .jpeg para gráficos, .csv para tablas.
#' Palette_color: Defina paleta de colores para gráficos. Explore paletas adicionales del <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>paquete R MetBrewer</a>
#' Output:1. Si Save as plot TRUE, extensiones: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf), SVG (*.svg). Ejemplo: <b>/Users/myPC/Documents/name_lcz_anomaly.png</b>;</p><p>
#'       :2. Si FALSE, extensión: tabla (.csv). Ejemplo: <b>/Users/myPC/Documents/name_lcz_anomaly.csv</b>
#' ALG_DESC: Esta función calcula anomalías térmicas para diferentes LCZs.</p><p>
#'         :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_anomaly.html'>Funciones Locales LCZ (Anomalías Térmicas)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0