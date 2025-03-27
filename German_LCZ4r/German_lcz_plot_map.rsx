##LCZ4r Allgemeine Funktionen=group
##Visualisiere LCZ-Karte=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|LCZ-Karte eingeben|None
##QgsProcessingParameterBoolean|display|Plot visualisieren (.html)|True
##QgsProcessingParameterString|Title|Titel|Lokale Klimazonen|optional|true
##QgsProcessingParameterString|Subtitle|Untertitel|Meine Stadt|optional|true
##QgsProcessingParameterString|Caption|Beschreibung|Quelle: LCZ4r, 2024.|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Legende anzeigen|True
##QgsProcessingParameterNumber|Height|Höhe des Plots|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Breite des Plots|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Auflösung (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|inclusive|Farben für Farbenblinde|False
##QgsProcessingParameterFileDestination|Output|Bild speichern|PNG-Dateien (*.png)

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

#' LCZ_map: Ein SpatRaster-Objekt mit der LCZ-Karte (aus *Obtain LCZ map*-Funktionen)
#' display: Bei TRUE wird der Plot im Browser als HTML-Visualisierung angezeigt.
#' Show_LCZ_legend: Bei TRUE wird die LCZ-Legende eingeblendet.
#' inclusive: Logisch. TRUE verwendet eine farbenblindenfreundliche Palette.
#' Output: Unterstützte Dateiformate: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       : Beispiel: <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: Diese Funktion erzeugt eine grafische Darstellung einer LCZ-Karte (Lokale Klimazonen).</p><p>
#'         :Weitere Informationen: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ allgemeine Funktionen</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r-Projekt</a>  
#' ALG_VERSION: 0.1.0