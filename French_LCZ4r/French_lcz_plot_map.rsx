##LCZ4r Fonctions générales=group
##Visualiser la carte LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Entrez la carte LCZ|None
##QgsProcessingParameterBoolean|display|Visualiser le graphique (.html)|True
##QgsProcessingParameterString|Title|Titre|Zones Climatiques Locales|optional|true
##QgsProcessingParameterString|Subtitle|Sous-titre|Ma Ville|optional|true
##QgsProcessingParameterString|Caption|Légende|Source : LCZ4r, 2024.|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Afficher la légende|True
##QgsProcessingParameterNumber|Height|Hauteur du graphique|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largeur du graphique|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Résolution (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|inclusive|Palette pour daltoniens|False
##QgsProcessingParameterFileDestination|Output|Enregistrer l'image|Fichiers PNG (*.png)


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


#' LCZ_map: Un objet SpatRaster contenant la carte LCZ (issues des fonctions *Obtain LCZ map*)
#' display: Si TRUE, le graphique s'affichera dans le navigateur en HTML.
#' Show_LCZ_legend: Si TRUE, la légende LCZ sera incluse.
#' inclusive: Logique. TRUE active une palette adaptée aux daltoniens.
#' Output: Formats supportés : PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       : Exemple : <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: Cette fonction génère une représentation graphique d'une carte de Zones Climatiques Locales (LCZ).</p><p>
#'         : Pour plus d'informations : <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Fonctions générales LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0

