##LCZ4r Allgemeine Funktionen=group
##Visualisiere LCZ Parameterkarte=name 
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map_parameter|LCZ Parameterkarte eingeben|None
##QgsProcessingParameterEnum|Select_parameter|Parameter auswählen|SVFmean;SVFmax;SVFmin;z0;ARmean;ARmax;ARmin;BSFmean;BSFmax;BSFmin;ISFmean;ISFmax;ISFmin;PSFmean;PSFmax;PSFmin;TSFmean;TSFmax;TSFmin;HREmean;HREmax;HREmin;TRCmean;TRCmax;TRCmin;SADmean;SADmax;SADmin;SALmean;SALmax;SALmin;AHmean;AHmax;AHmin|-1|0|False
##QgsProcessingParameterBoolean|display|Plot visualisieren (.html)|True
##QgsProcessingParameterString|Subtitle|Untertitel|Meine Stadt|optional|true
##QgsProcessingParameterString|Caption|Beschreibung|Quelle: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Höhe des Plots|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Breite des Plots|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Auflösung (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterFileDestination|Output|Bild speichern|PNG-Dateien (*.png)

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


#' LCZ_map_parameter: Der SpatRaster im Stack-Format aus der Funktion "Retrieve LCZ parameter".
#' display: Wenn TRUE, wird die Grafik im Webbrowser als HTML-Visualisierung angezeigt.
#' Select_parameter: Wählen Sie einen einzelnen Parameternamen aus, basierend auf Mittel-, Maximal- oder Minimalwerten:</p><p>
#'             : <b>SVF</b>: Sky View Factor [0-1]. </p><p>
#'             : <b>z0</b>: Rauhigkeitslänge [Meter]. </p><p>
#'             : <b>AR</b>: Aspect Ratio (Seitenverhältnis) [0-3]. </p><p> 
#'             : <b>BSF</b>: Building Surface Fraction (Gebäudeflächenanteil) [%]. </p><p> 
#'             : <b>ISF</b>: Impervious Surface Fraction (Versiegelter Flächenanteil) [%]. </p><p>  
#'             : <b>PSF</b>: Pervious Surface Fraction (Durchlässiger Flächenanteil) [%]. </p><p>  
#'             : <b>TSF</b>: Tree Surface Fraction (Baumflächenanteil) [%]. </p><p>  
#'             : <b>HRE</b>: Height Roughness Elements (Höhe der Rauheitselemente) [Meter]. </p><p>  
#'             : <b>TRC</b>: Terrain Roughness Class (Geländerauhigkeitsklasse) [Meter]. </p><p>
#'             : <b>SAD</b>: Surface Admittance (Oberflächenleitwert) [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Surface Albedo (Oberflächenalbedo) [0 - 0,5]. </p><p> 
#'             : <b>AH</b>: Anthropogenic Heat Output (Anthropogene Wärmeabgabe) [W m-2]. </p><p> 
#' Output: Unterstützte Dateiformate: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       :Beispiel: <b>/Users/myPC/Documents/name_lcz_par.jpeg</b>
#' ALG_DESC: Diese Funktion erzeugt eine grafische Darstellung einer Local Climate Zone (LCZ)-Karte als SpatRaster-Objekt.</p><p>
#'         :Weitere Informationen: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ allgemeine Funktionen</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r-Projekt</a>  
#' ALG_VERSION: 0.1.0