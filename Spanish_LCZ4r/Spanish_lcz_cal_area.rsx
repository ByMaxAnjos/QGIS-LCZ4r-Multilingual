##LCZ4r Funciones generales=group
##Calcular Áreas LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Mapa LCZ|None
##QgsProcessingParameterEnum|Select_plot_type|Tipo de gráfico|Barras;Pastel;Anillo|-1|0|False
##QgsProcessingParameterBoolean|display|Visualizar gráfico (.html)|True
##QgsProcessingParameterString|Title|Título|Zonas Climáticas Locales|optional|true
##QgsProcessingParameterString|Subtitle|Subtítulo|Mi Ciudad|optional|true
##QgsProcessingParameterString|Caption|Leyenda|Fuente: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|xlab|Etiqueta eje x|Código LCZ|optional|true
##QgsProcessingParameterString|ylab|Etiqueta eje y|Área [kilómetros cuadrados]|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Mostrar leyenda|True
##QgsProcessingParameterNumber|Height|Altura del gráfico|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Ancho del gráfico|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Resolución (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Guardar como gráfico|True
##QgsProcessingParameterFileDestination|Output|Guardar imagen|Archivos PNG (*.png)

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


#' LCZ_map: Objeto SpatRaster con el mapa LCZ (de funciones *Descargar mapa LCZ*).
#' Select_plot_type: Tipo de gráfico. Opciones: <b>Barras</b>, <b>Pastel</b>, <b>Anillo</b> </p><p>
#' display: Si es TRUE, el gráfico se muestra en el navegador como HTML.
#' Save_as_plot: Si es TRUE, guarda el gráfico; si no, una tabla (.csv). El formato depende de *Output* (.png/.csv).
#' Show_LCZ_legend: Si es TRUE, muestra la leyenda LCZ.
#' Output: 1. Si *Save_as_plot=TRUE*: extensiones válidas (.png, .jpg, .tif, .pdf, .svg). Ejemplo: <b>/Users/miPC/Documentos/area_lcz.png</b>;</p><p>
#'        : 2. Si *Save_as_plot=FALSE*: guarda tabla (.csv). Ejemplo: <b>/Users/miPC/Documentos/area_lcz.csv</b>
#' ALG_DESC: Calcula áreas de clases LCZ en porcentaje y kilómetros cuadrados.</p><p>
#'          : Más información: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Documentación LCZ4r</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Proyecto LCZ4r</a>
#' ALG_VERSION: 0.1.0
