##LCZ4r Funções Locais=group
##Analisar Intensidade de Ilha de Calor Urbana=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Dados de entrada|5
##QgsProcessingParameterField|variable|Selecione a variável temperatura do ar|Tabela|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Selecione o ID das Estações|Tabela|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Data inicial|DD-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Data final|DD-MM-AAAA|False
##QgsProcessingParameterEnum|Time_frequency|Frequência Temporal|Horária;Diária;Semanal;Mensal;Sazonal;Trimestral;Anual;Ano|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Preencher valores faltantes|Média;Mediana;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Method|Selecione o método para calcular a Ilha de Calor Urbana (ICU)|LCZ;Manual|-1|0|False
##QgsProcessingParameterString|Urban_station_reference|Selecione a estação urbana de referência|None|optional|true
##QgsProcessingParameterString|Rural_station_reference|Selecione a estação rural de referência|None|optional|true
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|Exibir estações urbanas e rurais|True
##QgsProcessingParameterEnum|Select_extract_type|Selecione o método de extração|Simples;Duas Etapas;Bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Dividir dados por|Ano;Estação;Estação por Ano;Mês;Meses por Ano;Dia Útil;Fim de Semana;Hora;Ciclo Diurno;Ciclo Diurno por Mês;Ciclo Diurno por Estação;Ciclo Diurno por Ano|-1|None|True
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locais|optional|true
##QgsProcessingParameterString|xlab|Rótulo eixo x|Tempo|optional|true
##QgsProcessingParameterString|ylab|Rótulo eixo y|Temperatura do Ar [ºC]|optional|true
##QgsProcessingParameterString|ylab2|Rótulo eixo y 2|ICU [ºC]|optional|true
##QgsProcessingParameterString|Caption|Fonte|Fonte: LCZ4r, 2024.|optional|true
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

#' LCZ_map: Um objeto no formato <b>SpatRaster</b> derivado das funções <em>"Baixar Mapa LCZ"<em>.
#' INPUT: Uma tabela (.csv), contendo os dados de variáveis ambientais estruturados assim:</p><p>
#'      :1. <b>Data</b>: Coluna com informações data-hora. Nomeie como <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Estação</b>: Coluna identificando as estações meteorológicas;</p><p>
#'      :3. <b>Variável</b>: Coluna representando a variável a ser interpolada. (ex: Temperatura do Ar, Umidade Relativa);</p><p>
#'      :4. <b>Latitude e Longitude</b>: Duas colunas com coordenadas geográficas. Nomeie como <code style='background-color: lightblue;'>lat|latitude e lon|long|longitude</code>.</p><p>
#'      :Formato data-hora: Deve seguir convenções R, como <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formatos que são aceitos: "1/2/1999" ou "AAAA-MM-DD", "1999-02-01".</p><p>
#'      :Para mais informações, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>"Dados de exemplo"</a> 
#' variable: Selecione a coluna referente a variável temperatura do ar (ex: airT).
#' station_id: Selecione a columa de identificação das estações meteorológicas (ex: station, site, id).
#' Date_start: Data de início no formato <b>DD-MM-AAAA [01-09-1986]</b>.
#' Date_end: Data final no mesmo formato.
#' Time_frequency: Define a resolução temporal para os quais dados são arredondados. O padrão é "Horária". Resoluções suportadas incluem: Horária, Diária, Semanal, Mensal, Sazonal, Trimestral ou Anual.
#' Impute_missing_values: Método para preencher valores faltantes ("Média", "Mediana", "knn", "bag").
#' Select_extract_type: Método para atribuir classe LCZ a estações. Padrão "Simples". Opções de Métodos:</p><p>
#'      :1. <b>Simples</b>: Atribui classe LCZ baseada no valor da célula em formato raster. Usado em redes de baixa densidade.</p><p>
#'      :2. <b>Duas Etapas</b>: Atribui classes LCZs filtrando estações em áreas heterogêneas. Requer ≥80% de pixels correspondentes em kernel 5×5 (Daniel et al., 2017). Reduz o número de estações. Recomendado para redes de ultra e alta densidade.</p><p>
#'      :3. <b>Bilinear</b>: Interpola valores LCZ das quatro células raster mais próximas.</p><p>
#' Split_data_by: Determina como a série temporal é segmentada. Opções: Ano, Mês, Ciclo Diurno, etc. </p><p> Combinações possíveis são: Ciclo Diurno por Mês, Ciclo Diurno por Estação ou Ciclo Diurno por Ano (Frequência ≥ "Hora").</p><p>
#'              :Detalhes: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>"Argumento type no pacote R openair"</a>.
#' Method: Método para calcular intensidade ICU. Opções: "LCZ" e "Manual". </p><p> No método "LCZ", a função identifica automaticamente tipos de classe LCZ (LCZ 1-10 para temperatura urbana, LCZ 11-16 para rural).</p><p>
#'       :No "Manual", os usuários selecionam as estações de referência.
#' Urban_station_reference: Com o método "Manual": selecione o nome da estação urbana de referência na coluna de identificação das estações <b>Estação_id</b>.
#' Rural_station_reference: Com o método "Manual": selecione o nome da estação rural de referência na coluna de identificação das estações <b>Estação_id</b>.
#' Group_urban_and_rural_temperatures: Se a opção "Exibir estações urbanas e rurais" estiver selecionada, a função agrupa temperaturas urbanas e rurais no mesmo gráfico.
#' display: Se a opção "Visualizar gráfico" estiver selecionada, a função exibe o gráfico no navegador como HTML.
#' Save_as_plot: Se a opção "Salvar como gráfico" estiver selecionada, salva um gráfico, se não estiver, gera uma tabela (tabela.csv). As extensões disponíveis são: .jpeg para gráficos, e  .csv para tabelas.
#' Output: Se a opção "Salvar como gráfico" estiver selecionada, gera um gráfico disponível nas extensões: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Exemplo: <b>/Users/myPC/Documents/lcz_uhi.png</b>;</p><p>
#'       :Se a opção "Salvar como gráfico" não estiver selecionada, gera uma tabela (.csv). Exemplo: <b>/Users/myPC/Documents/lcz_uhi.csv</b>
#' ALG_DESC: Esta função calcula a intensidade da Ilha de Calor Urbana (ICU), baseada em medições de temperatura e Zonas Climáticas Locais (LCZ).</p><p>
#'         : Para mais informações, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_uhi.html'>Funções Locais LCZ (Análise ICU)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0