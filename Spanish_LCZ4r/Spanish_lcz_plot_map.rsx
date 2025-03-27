##LCZ4r Funciones Generales=group
##Visualizar Mapa LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Ingrese el mapa LCZ|None
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locales|optional|true
##QgsProcessingParameterString|Subtitle|Subtítulo|Mi Ciudad|optional|true
##QgsProcessingParameterString|Caption|Leyenda|Fuente: LCZ4r, 2024.|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Mostrar leyenda|True
##QgsProcessingParameterNumber|Height|Altura del gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Ancho del gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolución (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|inclusive|Paleta para daltónicos|False
##QgsProcessingParameterFileDestination|Output|Guardar imagen|Archivos PNG (*.png)


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

#' LCZ_map: Un objeto SpatRaster con el mapa LCZ (de las funciones *Obtain LCZ map*)
#' display: Si TRUE, el gráfico se mostrará en el navegador como HTML.
#' Show_LCZ_legend: Si TRUE, se incluirá la leyenda LCZ.
#' inclusive: Lógico. TRUE usa una paleta para daltónicos.
#' Output: Formatos admitidos: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       : Ejemplo: <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: Esta función genera una representación gráfica de un mapa de Zonas Climáticas Locales (LCZ).</p><p>
#'         : Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funciones generales LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0

