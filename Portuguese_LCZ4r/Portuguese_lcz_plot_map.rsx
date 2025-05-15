##LCZ4r Funções Gerais=group
##Visualizar Mapa LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Insira o mapa LCZ|None
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locais|optional|true
##QgsProcessingParameterString|Subtitle|Subtítulo|Minha Cidade|optional|true
##QgsProcessingParameterString|Caption|Fonte|Fonte: LCZ4r, 2024.|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Mostrar legenda|True
##QgsProcessingParameterNumber|Height|Altura do gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largura do gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolução (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|inclusive|Cores para daltônicos|False
##QgsProcessingParameterFileDestination|Output|Salvar imagem|Arquivos PNG (*.png)


library(LCZ4r)
library(ggplot2)
library(terra)
library(ggiraph)
library(htmlwidgets)

LCZ_map <- terra::rast(LCZ_map)

# Generate and plot the LCZ map
plot_lcz<-LCZ4r::lcz_plot_map(LCZ_map, 
            show_legend=Show_LCZ_legend,
            title = Title, 
            subtitle=Subtitle, 
            caption = Caption, 
            inclusive=inclusive)
 # Plot visualization
if (display) {
        # Save the interactive plot as an HTML file
html_file <- file.path(tempdir(), "LCZ4rPlot.html")
ggiraph::girafe(
  ggobj = plot_lcz,
  width_svg = 14,
  height_svg = 9,
  options = list(
    opts_sizing(rescale = TRUE, width = 1),
       opts_tooltip(css = "background-color: white; color: black; 
                     font-size: 14px; padding: 10px; border-radius: 5px;"),
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
ggplot2::ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)

#' LCZ_map: Um objeto no formato SpatRaster contendo o mapa LCZ (gerado pelas funções <em>"Baixar Mapa LCZ"<em>)
#' display: Se a opção "Visualizar gráfico" estiver selecionada, o gráfico será exibido no navegador como HTML.
#' Show_LCZ_legend: Se a opção "Mostrar legenda" estiver selecionada, a legenda LCZ será incluída no mapa.
#' inclusive: Se a opção "Cores para daltônicos" estiver selecionada, será aplicado uma paleta de cores específicas para daltônicos.
#' Output: As opções de formatos suportados disponíveis: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       : Exemplo: <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: Esta função gera uma representação gráfica de um mapa de Zonas Climáticas Locais (LCZ).</p><p>
#'         : Para mais informações, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funções gerais LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0
