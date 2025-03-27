##LCZ4r Fonctions Générales=group
##Calculer les aires LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Carte LCZ|None
##QgsProcessingParameterEnum|Select_plot_type|Type de graphique|Barre;Camembert;Anneau|-1|0|False
##QgsProcessingParameterBoolean|display|Afficher le graphique (.html)|True
##QgsProcessingParameterString|Title|Titre|Zones climatiques locales|optional|true
##QgsProcessingParameterString|Subtitle|Sous-titre|Ma Ville|optional|true
##QgsProcessingParameterString|Caption|Légende|Source : LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|xlab|Étiquette axe x|Code LCZ|optional|true
##QgsProcessingParameterString|ylab|Étiquette axe y|Aire [kilomètres carrés]|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Afficher la légende|True
##QgsProcessingParameterNumber|Height|Hauteur du graphique|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largeur du graphique|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Résolution (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Enregistrer comme graphique|True
##QgsProcessingParameterFileDestination|Output|Enregistrer l'image|Fichiers PNG (*.png)

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



#' LCZ_map: Un objet SpatRaster contenant la carte LCZ (issue des fonctions Télécharger la carte LCZ).
#' Select_plot_type: Type de visualisation. Options : <b>Barre</b>, <b>Camembert</b>, <b>Anneau</b> </p><p>
#' display: Si TRUE, le graphique s'affiche dans le navigateur en HTML.
#' Save_as_plot: Si TRUE, enregistre le graphique ; sinon, enregistre un tableau (.csv). Format de sortie lié à Output (.png/.csv).
#' Show_LCZ_legend: Si TRUE, la légende LCZ est incluse.
#' Output: 1. Si Enregistrer comme graphique=TRUE: extensions autorisées (.png, .jpg, .tif, .pdf, .svg). Exemple : <b>/Users/monPC/Documents/nom_aire_lcz.png</b>;</p><p>
#'        : 2. Si Enregistrer comme graphique=FALSE: enregistre un tableau (.csv). Exemple : <b>/Users/monPC/Documents/nom_aire_lcz.csv</b>
#' ALG_DESC: Calcule les aires des classes LCZ en pourcentage et kilomètres carrés.</p><p>
#'          : Plus d'informations: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Documentation LCZ4r</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>
#' ALG_VERSION: 0.1.0
