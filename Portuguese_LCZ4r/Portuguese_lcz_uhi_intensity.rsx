##LCZ4r Funções Locais=group
##Analisar Intensidade de Ilha de Calor Urbana=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Dados de entrada|5
##QgsProcessingParameterField|variable|Coluna da variável alvo|Tabela|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Coluna de identificação das estações|Tabela|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Data inicial|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Data final|DD-MM-AAAA|False
##QgsProcessingParameterEnum|Time_frequency|Frequência Temporal|hora;dia;dia_de_verão;semana;mês;estação;trimestre;ano|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Imputar valores faltantes|média;mediana;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Method|Selecione o método ICU|LCZ;manual|-1|0|False
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|Exibir estações urbanas e rurais|True
##QgsProcessingParameterEnum|Select_extract_type|Método de extração|simples;dois.passos;bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir dados por|ano;estação;estaçãoano;mês;mêsano;dia.semana;fim.semana;horário.verão;hora;luz.dia;luz.dia-mês;luz.dia-estação;luz.dia-ano|-1|None|True
##QgsProcessingParameterString|Urban_station_reference|Referência estação urbana|None|optional|true
##QgsProcessingParameterString|Rural_station_reference|Referência estação rural|None|optional|true
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locais|optional|true
##QgsProcessingParameterString|xlab|Rótulo eixo x|Tempo|optional|true
##QgsProcessingParameterString|ylab|Rótulo eixo y|Temperatura do Ar [ºC]|optional|true
##QgsProcessingParameterString|ylab2|Rótulo eixo y 2|ICU [ºC]|optional|true
##QgsProcessingParameterString|Caption|Legenda|Fonte: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Altura (polegadas)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largura (polegadas)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolução (DPI)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Salvar como gráfico|True
##QgsProcessingParameterFileDestination|Output|Salvar imagem|Arquivos PNG (*.png)

library(LCZ4r)
library(sf)
library(ggplot2)
library(terra)
library(lubridate)
library(ggiraph)
library(htmlwidgets)

time_options <- c("hour", "day", "DSTday", "week", "month", "season", "quater", "year")
if (!is.null(Time_frequency) && Time_frequency >= 0 && Time_frequency < length(time_options)) {
  result_time <- time_options[Time_frequency + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_time <- NULL  
}
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
                        time.freq = result_time, 
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
                        time.freq = result_time, 
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
#' Time_frequency: Define a resolução temporal para cálculo de médias. O padrão é hora. Resoluções suportadas incluem: hora, dia, dia_de_verão, semana, mês, trimestre e ano.
#' Impute_missing_values: Método para imputar valores faltantes ("média", "mediana", "knn", "bag").
#' Select_extract_type: Método para atribuir classe LCZ a estações. Padrão "simples". Métodos:</p><p>
#'      :1. <b>simples</b>: Atribui classe LCZ baseada no valor da célula raster. Usado em redes de baixa densidade.</p><p>
#'      :2. <b>dois.passos</b>: Atribui LCZs filtrando estações em áreas heterogêneas. Requer ≥80% de pixels correspondentes em kernel 5×5 (Daniel et al., 2017). Reduz número de estações. Para redes ultra e alta densidade.</p><p>
#'      :3. <b>bilinear</b>: Interpola valores LCZ das quatro células raster mais próximas.</p><p>
#' Split_data_by: Determina como a série temporal é segmentada. Opções: ano, mês, luz do dia, horário de verão, etc. Combinações como luz.dia-mês, luz.dia-estação ou luz.dia-ano (frequência ≥ "hora").</p><p>
#'              :Detalhes: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argumento type no pacote R openair</a>.
#' Method: Método para calcular intensidade ICU. Opções: "LCZ" e "manual". No método "LCZ", a função identifica automaticamente tipos LCZ (LCZ 1-10 para temperatura urbana, LCZ 11-16 para rural).</p><p>
#'       :No "manual", usuários selecionam estações de referência.
#' Urban_station_reference: Com método "manual": selecione estação urbana de referência na coluna <b>station_id</b>.
#' Rural_station_reference: Com método "manual": selecione estação rural de referência na coluna <b>station_id</b>.
#' Group_urban_and_rural_temperatures: Se TRUE, agrupa temperaturas urbanas e rurais no mesmo gráfico.
#' display: Se TRUE, exibe o gráfico no navegador como HTML.
#' Save_as_plot: Se TRUE salva um gráfico, senão um dataframe (table.csv). Extensões: .jpeg para gráficos, .csv para tabelas.
#' Output: Se Save as plot TRUE: extensões PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Exemplo: <b>/Users/myPC/Documents/lcz_uhi.png</b>;</p><p>
#'       :Se FALSE: tabela (.csv). Exemplo: <b>/Users/myPC/Documents/lcz_uhi.csv</b>
#' ALG_DESC: Esta função calcula a intensidade da Ilha de Calor Urbana (ICU) baseada em medições de temperatura e Zonas Climáticas Locais (LCZ).</p><p>
#'         :Mais informações: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_uhi.html'>Funções Locais LCZ (Análise ICU)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0