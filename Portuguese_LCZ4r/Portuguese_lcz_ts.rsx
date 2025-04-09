##LCZ4r Funções Locais=group
##Analisar Séries Temporais LCZ = name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Dados de entrada|5
##QgsProcessingParameterField|variable|Coluna da variável alvo|Tabela|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Coluna de identificação das estações|Tabela|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Data inicial|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Data final|DD-MM-AAAA|False
##QgsProcessingParameterEnum|Time_frequency|Frequência Temporal|hora;dia;dia_de_verão;semana;mês;estação;trimestre;ano|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Selecione o método de extração|simples;dois.passos;bilinear|-1|2|False
##QgsProcessingParameterEnum|Split_data_by|Dividir dados por|ano;estação;estaçãoano;mês;mêsano;dia.semana;fim.semana;horário.verão;hora;luz.dia;luz.dia-mês;luz.dia-estação;luz.dia-ano|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|média;mediana;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|Selecione o tipo de gráfico|linha.básica;linha.facetada;mapa.calor;listras.aquecimento|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Escolha a paleta de cores|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Egito;Grego;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronese|-1|0|False
##QgsProcessingParameterBoolean|Smooth_trend_line|Suavizar linha de tendência|False
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locais|optional|true
##QgsProcessingParameterString|xlab|Rótulo eixo x|Tempo|optional|true
##QgsProcessingParameterString|ylab|Rótulo eixo y|Temperatura do Ar [°C]|optional|true
##QgsProcessingParameterString|Caption|Legenda|Fonte: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Nome da legenda (apenas mapa de calor e listras)|None|optional|true
##QgsProcessingParameterNumber|Height|Altura do gráfico (polegadas)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largura do gráfico (polegadas)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolução (DPI)|QgsProcessingParameterNumber.Integer|300
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
                          time.freq = result_time,
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
                         time.freq = result_time,
                         extract.method = result_extract,
                         by = result_by,
                         iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
#' LCZ_map: Um objeto <b>SpatRaster</b> derivado das funções <em>Baixar mapa LCZ</em>.
#' INPUT: Um dataframe (.csv) contendo dados de variáveis ambientais estruturados da seguinte forma:</p><p>
#'      :1. <b>date</b>: Uma coluna com informações de data-hora. Garanta que a coluna seja nomeada como <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>station</b>: Uma coluna especificando identificadores de estações meteorológicas;</p><p>
#'      :3. <b>variable</b>: Uma coluna representando a variável ambiental (ex: temperatura do ar, umidade relativa);</p><p>
#'      :4. <b>Latitude e Longitude</b>: Duas colunas fornecendo as coordenadas geográficas. Garanta que as colunas sejam nomeadas como <code style='background-color: lightblue;'>lat|latitude e lon|long|longitude</code>.</p><p>
#'      :Nota de formatação: O formato data-hora deve seguir as convenções do R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formatos aceitos: "1/2/1999" ou "AAAA-MM-DD", "1999-02-01".</p><p>
#'      :Mais informações: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>dados de exemplo</a> 
#' variable: O nome da coluna da variável alvo no dataframe (ex: airT e RH).
#' station_id: A coluna no dataframe que identifica estações meteorológicas (ex: station, site, id).
#' Date_start: Especifique as datas de início para análise. O formato deve ser <b>DD-MM-AAAA [01-09-1986]</b>.
#' Date_end: Data final, formatada igual à data inicial.
#' Time_frequency: Define a resolução temporal para cálculo de médias. O padrão é hora. Resoluções suportadas incluem: hora, dia, dia_de_verão, semana, mês, trimestre e ano.
#' Select_extract_type: String especificando o método para atribuir a classe LCZ a cada ponto de estação. Padrão é "simples". Métodos disponíveis:</p><p>
#'      :1. <b>simples</b>: Atribui a classe LCZ baseada no valor da célula raster onde o ponto está. Usado em redes de observação de baixa densidade.</p><p>
#'      :2. <b>dois.passos</b>: Atribui LCZs filtrando estações em áreas LCZ heterogêneas. Requer ≥80% de pixels em um kernel 5×5 correspondendo ao LCZ do pixel central (Daniel et al., 2017). Reduz o número de estações. Usado em redes ultra e alta densidade.</p><p>
#'      :3. <b>bilinear</b>: Interpola valores LCZ das quatro células raster mais próximas ao ponto.</p><p>
#' Split_data_by: Determina como a série temporal é segmentada. Opções: ano, mês, luz do dia, horário de verão, etc. Combinações como luz.dia-mês, luz.dia-estação ou luz.dia-ano (garanta frequência temporal como "hora").</p><p>
#'              :Detalhes: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type no pacote R openair</a>.
#' Smooth_trend_line: Opcionalmente, habilita uma linha de tendência suavizada usando Modelo Aditivo Generalizado (GAM). Padrão FALSE.
#' display: Se TRUE, o gráfico será exibido no navegador como visualização HTML.
#' Select_plot_type: Escolha o tipo de visualização. Opções:</p><p>
#'      :1. <b>linha.básica</b>: Gráfico de linha padrão</p><p>
#'      :2. <b>linha.facetada</b>: Gráfico de linha dividido por facetas (LCZ ou estação)</p><p>
#'      :3. <b>mapa.calor</b>: Representação de mapa de calor</p><p>
#'      :4. <b>listras.aquecimento</b>: Visualização inspirada em listras de aquecimento climático</p><p>
#' Impute_missing_values: Método para imputar valores faltantes ("média", "mediana", "knn", "bag").
#' Save_as_plot: Escolha se salva a saída como gráfico (TRUE) ou tabela (FALSE). Extensões: .jpeg para gráficos e .csv para tabelas.
#' Palette_color: Defina a paleta de cores. Explore paletas do <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>pacote R MetBrewer</a>
#' Output:1. Se Save as plot TRUE, extensões: PNG (.png), JPG (.jpg .jpeg), TTIF (.tif), PDF (*.pdf), SVG (*.svg);</p><p>
#'       :2. Se FALSE, extensão: tabela (.csv)
#' ALG_DESC: Esta função permite analisar temperatura do ar ou outras variáveis ambientais associadas a LCZ ao longo do tempo.</p><p>
#'         :Casos de uso detalhados: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_time_series.html'>Funções Locais LCZ (Análise de Séries Temporais)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0