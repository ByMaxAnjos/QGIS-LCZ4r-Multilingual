##LCZ4r Funciones Generales=group
##Visualizar Mapa de Parámetros LCZ=name 
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map_parameter|Ingrese el mapa de parámetros LCZ|None
##QgsProcessingParameterEnum|Select_parameter|Seleccione el parámetro|SVFmean;SVFmax;SVFmin;z0;ARmean;ARmax;ARmin;BSFmean;BSFmax;BSFmin;ISFmean;ISFmax;ISFmin;PSFmean;PSFmax;PSFmin;TSFmean;TSFmax;TSFmin;HREmean;HREmax;HREmin;TRCmean;TRCmax;TRCmin;SADmean;SADmax;SADmin;SALmean;SALmax;SALmin;AHmean;AHmax;AHmin|-1|0|False
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Subtitle|Subtítulo|Mi Ciudad|optional|true
##QgsProcessingParameterString|Caption|Leyenda|Fuente: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Altura del gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Ancho del gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolución (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterFileDestination|Output|Guardar imagen|Archivos PNG (*.png)

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


#' LCZ_map_parameter: El SpatRaster en formato stack de la función "Retrieve LCZ parameter".
#' display: Si TRUE, el gráfico se mostrará en el navegador como una visualización HTML.
#' Select_parameter: Seleccione un parámetro basado en valores medios, máximos o mínimos:</p><p>
#'             : <b>SVF</b>: Factor de Vista del Cielo [0-1]. </p><p>
#'             : <b>z0</b>: Longitud de Rugosidad [metros]. </p><p>
#'             : <b>AR</b>: Relación de Aspecto [0-3]. </p><p> 
#'             : <b>BSF</b>: Fracción de Superficie Edificada [%]. </p><p> 
#'             : <b>ISF</b>: Fracción de Superficie Impermeable [%]. </p><p>  
#'             : <b>PSF</b>: Fracción de Superficie Permeable [%]. </p><p>  
#'             : <b>TSF</b>: Fracción de Superficie Arbórea [%]. </p><p>  
#'             : <b>HRE</b>: Altura de Elementos de Rugosidad [metros]. </p><p>  
#'             : <b>TRC</b>: Clase de Rugosidad del Terreno [metros]. </p><p>
#'             : <b>SAD</b>: Admitancia de Superficie [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Albedo de Superficie [0 - 0,5]. </p><p> 
#'             : <b>AH</b>: Calor Antropogénico [W m-2]. </p><p> 
#' Output: Formatos admitidos: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       :Ejemplo: <b>/Users/myPC/Documents/name_lcz_par.jpeg</b>
#' ALG_DESC: Esta función genera una representación gráfica de un mapa de Zonas Climáticas Locales (LCZ) proporcionado como objeto SpatRaster.</p><p>
#'         :Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Funciones generales LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>  
#' ALG_VERSION: 0.1.0