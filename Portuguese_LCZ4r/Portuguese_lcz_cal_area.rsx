##LCZ4r Funções Gerais=group
##Calcular Áreas LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterEnum|Select_plot_type|Selecione o tipo de gráfico|Barras;Pizza;Rosca|-1|0|False
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locais|optional|true
##QgsProcessingParameterString|Subtitle|Subtítulo|Minha Cidade|optional|true
##QgsProcessingParameterString|Caption|Fonte|Fonte: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|xlab|Rótulo eixo x|Código LCZ|optional|true
##QgsProcessingParameterString|ylab|Rótulo eixo y|Área [quilômetros quadrados]|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Mostrar legenda|True
##QgsProcessingParameterNumber|Height|Altura do gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largura do gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolução (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Salvar como gráfico|True
##QgsProcessingParameterFileDestination|Output|Salvar imagem|Arquivos PNG (*.png)

library(LCZ4r)
library(terra)
library(ggiraph)
library(htmlwidgets)

# Load LCZ raster
LCZ_map <- terra::rast(LCZ_map)

# Check plot type selection
plots <- c("bar", "pie", "donut")
if (!is.null(Select_plot_type) && Select_plot_type >= 0 && Select_plot_type < length(plots)) {
  result_plot <- plots[Select_plot_type + 1] # Align with R's 1-based indexing
} else {
  result_plot <- "bar" # Default plot type if input is invalid
}

# Generate and plot LCZ data
if (Save_as_plot) {
    # Calculate areas and create the plot
    plot_lcz <- LCZ4r::lcz_cal_area(
        LCZ_map, 
        plot_type = result_plot,
        iplot = TRUE, 
        show_legend = Show_LCZ_legend,
        title = Title, 
        subtitle = Subtitle, 
        caption = Caption, 
        xlab = xlab, 
        ylab = ylab
    )

    # Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_lcz,
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

    # Save static plot
    ggplot2::ggsave(Output, plot = plot_lcz, height = Height, width = Width, dpi = dpi)
    
} else {
    # Calculate areas and save as a CSV
    tbl_lcz <- LCZ4r::lcz_cal_area(LCZ_map, iplot = FALSE)
    write.csv(tbl_lcz, Output, row.names = FALSE)
}


#' LCZ_map: Objeto em formato SpatRaster contendo o mapa LCZ (gerado pelo conjunto de funções <em>"Baixar Mapa LCZ"<em>).
#' Select_plot_type: Selecione o tipo de gráfico desejado. As opções disponíveis são: <b>Barras</b>, <b>Pizza</b>, <b>Rosca</b> </p><p>
#' display: Se a opção "Visualizar gráfico" estiver selecionada, o gráfico será exibido no navegador como HTML.
#' Save_as_plot: Se a opção "Salvar como gráfico" estiver selecionada, salva o gráfico; caso contrário, salva uma tabela (.csv). O formato está vinculado a saída da função (.png/.csv).
#' Show_LCZ_legend: Se a opção "Mostrar legenda" estiver selecionada, a função vai inserir a legenda das classes LCZ.
#' Output: 1. Se a opção "Salvar como gráfico" estiver selecionada, escolha um formato de arquivo: extensões permitidas (.png, .jpg, .tif, .pdf, .svg). Exemplo: <b>/Users/meuPC/Documentos/area_lcz.png</b>;</p><p>
#'        : 2. Se a opção "Salvar como gráfico" não estiver selecionada: salva uma tabela (.csv). Exemplo: <b>/Users/meuPC/Documentos/area_lcz.csv</b>
#' ALG_DESC: Calcula as áreas das classes LCZ em porcentagem e em quilômetros quadrados.</p><p>
#'          : Guias e mais informações em: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Documentação LCZ4r</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>
#' ALG_VERSION: 0.1.0
