##LCZ4r Funções Gerais=group
##Visualizar Mapa de Parâmetros LCZ=name 
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map_parameter|Insira o mapa de parâmetros LCZ|None
##QgsProcessingParameterEnum|Select_parameter|Selecione o parâmetro|SVFmean;SVFmax;SVFmin;z0;ARmean;ARmax;ARmin;BSFmean;BSFmax;BSFmin;ISFmean;ISFmax;ISFmin;PSFmean;PSFmax;PSFmin;TSFmean;TSFmax;TSFmin;HREmean;HREmax;HREmin;TRCmean;TRCmax;TRCmin;SADmean;SADmax;SADmin;SALmean;SALmax;SALmin;AHmean;AHmax;AHmin|-1|0|False
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Subtitle|Subtítulo|Minha Cidade|optional|true
##QgsProcessingParameterString|Caption|Fonte|Fonte: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Altura do gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largura do gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolução (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterFileDestination|Output|Salvar arquivo em formato de imagem|Arquivos PNG (*.png)

library(LCZ4r)
library(ggplot2)
library(terra)
library(ggiraph)
library(htmlwidgets)

# Define the mapping of indices to parameters
parameters <- c("SVFmean", "SVFmax", "SVFmin", 
                "ARmean", "ARmax", "ARmin", 
                "BSFmean", "BSFmax", "BSFmin", 
                "ISFmean", "ISFmax", "ISFmin", 
                "PSFmean", "PSFmax", "PSFmin", 
                "TSFmean", "TSFmax", "TSFmin", 
                "HREmean", "HREmax", "HREmin", 
                "TRCmean", "TRCmax", "TRCmin", 
                "SADmean", "SADmax", "SADmin", 
                "SALmean", "SALmax", "SALmin", 
                "AHmean", "AHmax", "AHmin", 
                "z0")

# Use the selected parameter index to retrieve the corresponding value
# Adjust for zero-based indexing
if (!is.null(Select_parameter) && Select_parameter >= 0 && Select_parameter < length(parameters)) {
  result_par <- parameters[Select_parameter + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_par <- NULL  # Handle invalid or missing selection
}

LCZ_map_parameter <- terra::rast(LCZ_map_parameter)

plot_lcz <- LCZ4r::lcz_plot_parameters(LCZ_map_parameter, iselect = result_par, subtitle=Subtitle, caption = Caption)


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


ggplot2::ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)


#' LCZ_map_parameter: O arquivo de empilhamento de parâmetros no formato Spatraster, </p><p> gerado pela função <em>"Gerar Parâmetros LCZ"<em>.
#' display: Se a opção "Visualizar gráfico" estiver selecionada, o gráfico será exibido no navegador como uma visualização HTML.
#' Select_parameter: Selecione um parâmetro com base em valores médios, máximos ou mínimos:</p><p>
#'             : <b>SVF</b>: Fator de Visão do Céu [0-1]. </p><p>
#'             : <b>z0</b>: Comprimento de Rugosidade [metros]. </p><p>
#'             : <b>AR</b>: Razão de Aspecto [0-3]. </p><p> 
#'             : <b>BSF</b>: Fração de Superfície Edificada [%]. </p><p> 
#'             : <b>ISF</b>: Fração de Superfície Impermeável [%]. </p><p>  
#'             : <b>PSF</b>: Fração de Superfície Permeável [%]. </p><p>  
#'             : <b>TSF</b>: Fração de Superfície Arbórea [%]. </p><p>  
#'             : <b>HRE</b>: Altura dos Elementos de Rugosidade [metros]. </p><p>  
#'             : <b>TRC</b>: Classe de Rugosidade do Terreno [metros]. </p><p>
#'             : <b>SAD</b>: Admitância da Superfície [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Albedo da Superfície [0 - 0,5]. </p><p> 
#'             : <b>AH</b>: Calor Antropogênico [W m-2]. </p><p> 
#' Output: As opções de formatos suportados disponíveis: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       :Exemplo: <b>/Users/myPC/Documents/name_lcz_par.jpeg</b>
#' ALG_DESC: Esta função gera uma representação gráfica de um mapa de Zonas Climáticas Locais (LCZ), fornecido como um objeto no formato SpatRaster.</p><p>
#'         : Para mais informações, visite: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funções Gerais LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0