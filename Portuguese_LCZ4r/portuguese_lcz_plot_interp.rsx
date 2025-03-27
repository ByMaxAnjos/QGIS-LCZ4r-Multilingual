##LCZ4r Funções Locais=group
##Visualizar Mapa LCZ Interpolado=name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|Raster_interpolated|Insira o mapa interpolado|None
##QgsProcessingParameterEnum|Palette_color|Paleta de cores|sombreada;viridi;árido;atlas;az_am_ve;profundo;vd_am;alto_relevo;rp_am_vd;roxo;suave|-1|0|False
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locais|optional|true
##QgsProcessingParameterString|Subtitle|Subtítulo|Minha Cidade|optional|true
##QgsProcessingParameterString|Legend|Legenda| TempAr[°C]|optional|true
##QgsProcessingParameterString|Caption|Descrição|Fonte: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Altura do gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largura do gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolução do gráfico (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterNumber|Number_of_columns|Número de colunas|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterNumber|Number_of_rows|Número de linhas|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterFileDestination|Output|Salvar imagem|Arquivos PNG (*.png)
library(LCZ4r)
library(ggplot2)
library(terra)
library(ggiraph)
library(htmlwidgets)


#Check color type
colors <- c("muted", "viridi", "arid", "atlas", "bl_yl_rd", "gn_yl", "high_relieg", "pi_y_g", "purple", "soft")
if (!is.null(Palette_color) && Palette_color >= 0 && Palette_color < length(colors)) {
  result_colors <- colors[Palette_color + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_colors <- NULL  # Handle invalid or missing selection
}


plot_map <- lcz_plot_interp(Raster_interpolated, 
                title = Title, 
                subtitle = Subtitle,
                caption = Caption,
                fill = Legend,
                palette=result_colors,
                ncol=Number_of_columns,
                nrow=Number_of_rows
                )
# Plot visualization
if (display) {
        # Save the interactive plot as an HTML file
html_file <- file.path(tempdir(), "LCZ4rPlot.html")
ggiraph::girafe(
  ggobj = plot_map,
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
ggsave(Output, plot_map, height = Height, width = Width, dpi = dpi)

#' Raster_interpolated: Um <b>SpatRaster</b> das <em>funções de interpolação LCZ</em>
#' Palette_color: Paletas de gradiente disponíveis no: <a href='https://dieghernan.github.io/tidyterra/articles/palettes.html#scale_fill_whitebox_'>pacote tidyterra</a> 
#' display: Se TRUE, o gráfico será exibido no navegador como visualização HTML.
#' Output: Especifica a extensão do arquivo: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf).</p><p>
#'       :Exemplo: <b>/Users/myPC/Documents/my_interp_map.png</b>
#' ALG_DESC: Esta função plota a anomalia LCZ interpolada, temperatura do ar LCZ ou outras variáveis ambientais.</p><p>
#'         :Mais informações: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>Funções Locais LCZ</a> 
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projeto LCZ4r</a>  
#' ALG_VERSION: 0.1.0