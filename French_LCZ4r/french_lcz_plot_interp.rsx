##LCZ4r Fonctions Locales=group
##Visualiser la carte LCZ interpolée=name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|Raster_interpolated|Entrez la carte interpolée|None
##QgsProcessingParameterEnum|Palette_color|Palette de couleurs|sourdes;viridi;aride;atlas;bl_yl_rd;profond;gn_yl;haut_relief;pi_y_g;violet;doux|-1|0|False
##QgsProcessingParameterBoolean|display|Afficher la visualisation (.html)|True
##QgsProcessingParameterString|Title|Titre|Zones Climatiques Locales|optional|true
##QgsProcessingParameterString|Subtitle|Sous-titre|Ma Ville|optional|true
##QgsProcessingParameterString|Legend|Légende| TempAir[°C]|optional|true
##QgsProcessingParameterString|Caption|Description|Source : LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Hauteur du graphique|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largeur du graphique|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Résolution du graphique (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterNumber|Number_of_columns|Nombre de colonnes|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterNumber|Number_of_rows|Nombre de lignes|QgsProcessingParameterNumber.Integer|1
##QgsProcessingParameterFileDestination|Output|Enregistrer l'image|Fichiers PNG (*.png)

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

#' Raster_interpolated: Un <b>SpatRaster</b> provenant des <em>fonctions d'interpolation LCZ</em>
#' Palette_color: Palettes dégradées disponibles dans le: <a href='https://dieghernan.github.io/tidyterra/articles/palettes.html#scale_fill_whitebox_'>package tidyterra</a> 
#' display: Si TRUE, le graphique s'affichera dans votre navigateur sous forme de visualisation HTML.
#' Output: Spécifie l'extension de fichier: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf).</p><p>
#'       :Exemple: <b>/Users/myPC/Documents/my_interp_map.png</b>
#' ALG_DESC: Cette fonction trace l'anomalie LCZ interpolée, la température de l'air LCZ ou d'autres variables environnementales.</p><p>
#'         :Plus d'informations: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>Fonctions locales LCZ</a> 
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0