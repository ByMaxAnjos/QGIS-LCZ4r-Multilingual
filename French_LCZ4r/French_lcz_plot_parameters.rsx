##LCZ4r Fonctions Générales=group
##Visualiser la carte des paramètres LCZ=name 
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map_parameter|Entrez la carte des paramètres LCZ|None
##QgsProcessingParameterEnum|Select_parameter|Sélectionnez le paramètre|SVFmean;SVFmax;SVFmin;z0;ARmean;ARmax;ARmin;BSFmean;BSFmax;BSFmin;ISFmean;ISFmax;ISFmin;PSFmean;PSFmax;PSFmin;TSFmean;TSFmax;TSFmin;HREmean;HREmax;HREmin;TRCmean;TRCmax;TRCmin;SADmean;SADmax;SADmin;SALmean;SALmax;SALmin;AHmean;AHmax;AHmin|-1|0|False
##QgsProcessingParameterBoolean|display|Visualiser le graphique (.html)|True
##QgsProcessingParameterString|Subtitle|Sous-titre|Ma Ville|optional|true
##QgsProcessingParameterString|Caption|Légende|Source : LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Hauteur du graphique|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largeur du graphique|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Résolution (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterFileDestination|Output|Enregistrer l'image|Fichiers PNG (*.png)


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


#' LCZ_map_parameter: Le SpatRaster au format stack provenant de la fonction "Retrieve LCZ parameter".
#' display: Si TRUE, le graphique sera affiché dans votre navigateur sous forme de visualisation HTML.
#' Select_parameter: Choisissez un paramètre unique basé sur les valeurs moyennes, maximales ou minimales:</p><p>
#'             : <b>SVF</b>: Facteur de vue du ciel [0-1]. </p><p>
#'             : <b>z0</b>: Longueur de rugosité [mètres]. </p><p>
#'             : <b>AR</b>: Rapport d'aspect [0-3]. </p><p> 
#'             : <b>BSF</b>: Fraction de surface bâtie [%]. </p><p> 
#'             : <b>ISF</b>: Fraction de surface imperméable [%]. </p><p>  
#'             : <b>PSF</b>: Fraction de surface perméable [%]. </p><p>  
#'             : <b>TSF</b>: Fraction de surface arborée [%]. </p><p>  
#'             : <b>HRE</b>: Hauteur des éléments de rugosité [mètres]. </p><p>  
#'             : <b>TRC</b>: Classe de rugosité du terrain [mètres]. </p><p>
#'             : <b>SAD</b>: Admittance de surface [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Albédo de surface [0 - 0,5]. </p><p> 
#'             : <b>AH</b>: Flux de chaleur anthropique [W m-2]. </p><p> 
#' Output: Formats de fichiers pris en charge : PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       :Exemple : <b>/Users/myPC/Documents/name_lcz_par.jpeg</b>
#' ALG_DESC: Cette fonction génère une représentation graphique d'une carte de Zone Climatique Locale (LCZ) fournie sous forme d'objet SpatRaster.</p><p>
#'         :Pour plus d'informations : <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Fonctions générales LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0