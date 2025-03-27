##LCZ4r Funciones Locales=group
##Analizar Series Temporales LCZ = name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Ingrese mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Datos de entrada|5
##QgsProcessingParameterField|variable|Columna de variable objetivo|Tabla|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Columna de identificación de estaciones|Tabla|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Fecha de inicio|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Fecha de fin|DD-MM-AAAA|False
##QgsProcessingParameterString|Time_frequency|Frecuencia temporal|hora|False
##QgsProcessingParameterEnum|Select_extract_type|Seleccione método de extracción|simple;dos.pasos;bilineal|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir datos por|año;temporada;temporadaaño;mes;mesaño;día.semana;fin.semana;horario.verano;hora;luz.día;luz.día-mes;luz.día-temporada;luz.día-año|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|media;mediana;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|Seleccione tipo de gráfico|línea.básica;línea.facetada;mapa.calor;rayas.calentamiento|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Elija paleta de colores|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Egipto;Griego;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronés|-1|0|False
##QgsProcessingParameterBoolean|Smooth_trend_line|Suavizar línea de tendencia|False
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locales|optional|true
##QgsProcessingParameterString|xlab|Etiqueta eje x|Tiempo|optional|true
##QgsProcessingParameterString|ylab|Etiqueta eje y|Temperatura del Aire [°C]|optional|true
##QgsProcessingParameterString|Caption|Leyenda|Fuente: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Nombre de leyenda (solo mapa de calor y rayas)|None|optional|true
##QgsProcessingParameterNumber|Height|Altura del gráfico (pulgadas)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Ancho del gráfico (pulgadas)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolución (PPP)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
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
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
}

#Check plot type
plots <- c("basic_line", "facet_line", "heatmap", "warming_stripes")
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

# Generate data.frame ----

INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

if (Save_as_plot == TRUE) {
        plot_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          time.freq = Time_frequency,
                          extract.method = result_extract,
                          smooth=Smooth_trend_line,
                          by = result_by,
                          plot_type=result_plot,
                          impute = result_imputes,
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
        tbl_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = my_table, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = Time_frequency,
                         extract.method = result_extract,
                         by = result_by,
                         iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
#' LCZ_map: Un objeto <b>SpatRaster</b> derivado de las funciones <em>Descargar mapa LCZ</em>.
#' INPUT: Un marco de datos (.csv) que contiene datos de variables ambientales estructurados así:</p><p>
#'      :1. <b>date</b>: Columna con información fecha-hora. Asegúrese que se llame <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>station</b>: Columna que identifica estaciones meteorológicas;</p><p>
#'      :3. <b>variable</b>: Columna que representa la variable ambiental (ej: temperatura del aire, humedad relativa);</p><p>
#'      :4. <b>Latitud y Longitud</b>: Dos columnas con coordenadas geográficas. Asegúrese que se llamen <code style='background-color: lightblue;'>lat|latitude y lon|long|longitude</code>.</p><p>
#'      :Nota de formato: El formato fecha-hora debe seguir convenciones R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> o <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceptados: "1/2/1999" o "AAAA-MM-DD", "1999-02-01".</p><p>
#'      :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>datos de ejemplo</a> 
#' variable: Nombre de la columna de variable objetivo (ej: airT y RH).
#' station_id: Columna que identifica estaciones meteorológicas (ej: station, site, id).
#' Date_start: Fecha de inicio en formato <b>DD-MM-AAAA [01-09-1986]</b>.
#' Date_end: Fecha final con mismo formato.
#' Time_frequency: Resolución temporal para promedios. Por defecto "hora". Opciones: "día", "semana", "mes" o "año". Personalizadas como "3 días", "2 semanas", etc.
#' Select_extract_type: Método para asignar clase LCZ a cada estación. Por defecto "simple". Métodos:</p><p>
#'      :1. <b>simple</b>: Asigna clase LCZ según valor de celda raster donde cae el punto. Usado en redes de baja densidad.</p><p>
#'      :2. <b>dos.pasos</b>: Asigna LCZs filtrando estaciones en áreas LCZ heterogéneas. Requiere ≥80% de píxeles en kernel 5×5 coincidiendo con píxel central (Daniel et al., 2017). Reduce número de estaciones. Usado en redes ultra y alta densidad.</p><p>
#'      :3. <b>bilineal</b>: Interpola valores LCZ de cuatro celdas raster más cercanas.</p><p>
#' Split_data_by: Segmentación de series temporales. Opciones: año, temporada, luz diurna, horario de verano, etc. Combinaciones como luz.día-mes, luz.día-temporada o luz.día-año (frecuencia ≥ "hora").</p><p>
#'              :Detalles: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type en paquete R openair</a>.
#' Smooth_trend_line: Opcionalmente, activa línea de tendencia suavizada con Modelo Aditivo Generalizado (GAM). Por defecto FALSE.
#' display: Si TRUE, muestra gráfico en navegador como HTML.
#' Select_plot_type: Tipo de visualización. Opciones:</p><p>
#'      :1. <b>línea.básica</b>: Gráfico de línea estándar</p><p>
#'      :2. <b>línea.facetada</b>: Gráfico de línea por facetas (LCZ o estación)</p><p>
#'      :3. <b>mapa.calor</b>: Representación de mapa de calor</p><p>
#'      :4. <b>rayas.calentamiento</b>: Visualización inspirada en rayas de calentamiento climático</p><p>
#' Impute_missing_values: Método para imputar valores faltantes ("media", "mediana", "knn", "bag").
#' Save_as_plot: Si TRUE guarda como gráfico, si FALSE como tabla (extensiones: .jpeg para gráficos, .csv para tablas).
#' Palette_color: Paleta de colores. Explore <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>paquete R MetBrewer</a>
#' Output:1. Si Save as plot TRUE: extensiones PNG (.png), JPG (.jpg .jpeg), TTIF (.tif), PDF (*.pdf), SVG (*.svg);</p><p>
#'       :2. Si FALSE: tabla (.csv)
#' ALG_DESC: Esta función permite analizar temperatura del aire u otras variables ambientales asociadas a LCZ en el tiempo.</p><p>
#'         :Casos de uso: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_time_series.html'>Funciones Locales LCZ (Análisis de Series Temporales)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0