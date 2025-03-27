##LCZ4r Funções Locais=group
##Calcular Anomalias LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Dados de entrada|5
##QgsProcessingParameterField|variable|Coluna da variável alvo|Tabela|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Coluna de identificação das estações|Tabela|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Data inicial|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Data final|DD-MM-AAAA|False
##QgsProcessingParameterEnum|Time_frequency|Frequência temporal|hora;dia;dia.verão;semana;mês;estação;trimestre;ano|-1|0|False
##QgsProcessingParameterString|Select_hour|Especificar uma hora|0:23|optional|True
##QgsProcessingParameterEnum|Select_extract_type|Selecione o método de extração|simples;dois.passos;bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir dados por|ano;estação;estaçãoano;mês;mêsano;dia.semana;fim.semana;horário.verão;hora;luz.dia;luz.dia-mês;luz.dia-estação;luz.dia-ano|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|média;mediana;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|Selecione o tipo de gráfico|barras_divergentes;barras;pontos;lollipop|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Escolha a paleta de cores|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Egito;Grego;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronese|-1|0|False
##QgsProcessingParameterString|Title|Título|Anomalias LCZ|optional|true
##QgsProcessingParameterString|xlab|Rótulo eixo x|Estações|optional|true
##QgsProcessingParameterString|ylab|Rótulo eixo y|Temperatura do Ar [ºC]|optional|true
##QgsProcessingParameterString|Caption|Legenda|Fonte: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Nome da legenda|Anomalia [ºC]|optional|true
##QgsProcessingParameterNumber|Height|Altura do gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largura do gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolução do gráfico (DPI)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterBoolean|Save_as_plot|Salvar como gráfico|True
##QgsProcessingParameterFileDestination|Output|Salvar sua imagem|Arquivos PNG (*.png)

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
 
#' LCZ_map: Um objeto <b>SpatRaster</b> derivado das funções <em>Baixar mapa LCZ</em>.
#' INPUT: Um dataframe (.csv) contendo dados de variáveis ambientais estruturados assim:</p><p>
#'      :1. <b>date</b>: Coluna com informações data-hora. Nomeie como <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Coluna identificando estações meteorológicas;</p><p>
#'      :3. <b>Variable</b>: Coluna representando a variável ambiental (ex: temperatura do ar, umidade relativa);</p><p>
#'      :4. <b>Latitude e Longitude</b>: Duas colunas com coordenadas geográficas. Nomeie como <code style='background-color: lightblue;'>lat|latitude e lon|long|longitude</code>.</p><p>
#'      :Formato data-hora: Deve seguir convenções R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceitos: "1/2/1999" ou "AAAA-MM-DD", "1999-02-01".</p><p>
#'      :Mais informações: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>dados de exemplo</a> 
#' variable: Nome da coluna da variável alvo (ex: airT, HR).
#' station_id: Coluna identificando estações meteorológicas (ex: station, site, id).
#' Date_start: Data de início no formato <b>DD-MM-AAAA [01-09-1986]</b>.
#' Date_end: Data final no mesmo formato.
#' Time_frequency: Resolução temporal para média. Padrão "hora". Opções: "hora", "dia", "dia.verão", "semana", "mês", "trimestre" ou "ano".
#' Select_extract_type: Método para atribuir classe LCZ a estações. Padrão "simples". Métodos:</p><p>
#'      :1. <b>simples</b>: Atribui classe LCZ baseada no valor da célula raster. Usado em redes de baixa densidade.</p><p>
#'      :2. <b>dois.passos</b>: Atribui LCZs filtrando estações em áreas heterogêneas. Requer ≥80% de pixels correspondentes em kernel 5×5 (Daniel et al., 2017). Reduz número de estações. Para redes ultra e alta densidade.</p><p>
#'      :3. <b>bilinear</b>: Interpola valores LCZ das quatro células raster mais próximas.</p><p>
#' Split_data_by: Determina como a série temporal é segmentada. Opções: ano, mês, luz do dia, horário de verão, etc. Combinações como luz.dia-mês, luz.dia-estação ou luz.dia-ano (resolução ≥ "hora").</p><p>
#'              :Detalhes: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type no pacote R openair</a>.
#' Select_hour: Especificar hora ou intervalo de horas de 0 a 23. Formatos possíveis:</p><p>
#'      :Intervalo: 0:12 seleciona horas 0 a 12 inclusive;</p><p>
#'      :Conjunto específico: c(1, 6, 18, 21) seleciona horas 1, 6, 18 e 21;</p><p>
#'      :Para dados diários, mensais ou anuais, deixe este parâmetro vazio.
#' Select_plot_type: Escolha entre:</p><p>
#'      :1. <b>barras_divergentes</b>: Gráfico de barras horizontais divergindo do centro (zero), com anomalias positivas à direita e negativas à esquerda. Ideal para mostrar extensão e direção das anomalias;</p><p>
#'      :2. <b>barras</b>: Gráfico de barras mostrando magnitude das anomalias por estação, coloridas por positivas/negativas. Bom para comparar anomalias entre estações;</p><p>
#'      :3. <b>pontos</b>: Gráfico de pontos exibindo valores médios e de referência, conectados por linhas. Tamanho/cor dos pontos indica magnitude da anomalia. Ideal para valores absolutos e anomalias;</p><p>
#'      :4. <b>lollipop</b>: Gráfico lollipop onde cada "haste" representa um valor de anomalia e os pontos no topo representam o tamanho da anomalia. Visualização clara de anomalias positivas/negativas.</p><p>
#' Impute_missing_values: Método para imputar valores faltantes: "média", "mediana", "knn", "bag".
#' display: Se TRUE, exibe o gráfico no navegador como HTML.
#' Save_as_plot: Se TRUE salva um gráfico, senão um dataframe (table.csv). Extensões: .jpeg para gráficos, .csv para tabelas.
#' Palette_color: Defina a paleta de cores para gráficos. Explore paletas adicionais do <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>pacote R MetBrewer</a>
#' Output:1. Se Save as plot TRUE, extensões: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf), SVG (*.svg). Exemplo: <b>/Users/myPC/Documents/name_lcz_anomaly.png</b>;</p><p>
#'       :2. Se FALSE, extensão: tabela (.csv). Exemplo: <b>/Users/myPC/Documents/name_lcz_anomaly.csv</b>
#' ALG_DESC: Esta função calcula anomalias térmicas para diferentes LCZs.</p><p>
#'         :Mais informações: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_anomaly.html'>Funções Locais LCZ (Anomalias Térmicas)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0