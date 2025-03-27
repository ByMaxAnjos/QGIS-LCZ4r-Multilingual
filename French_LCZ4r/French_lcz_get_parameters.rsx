##LCZ4r Fonctions Générales=group
##Générer Paramètres LCZ=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Entrer la carte LCZ|None
##QgsProcessingParameterBoolean|iStack|Enregistrer tous les paramètres en un seul|True
##QgsProcessingParameterEnum|Select_parameter|Sélectionner le paramètre|SVFmoy;SVFmax;SVFmin;z0;ARmoy;ARmax;ARmin;BSFmoy;BSFmax;BSFmin;ISFmoy;ISFmax;ISFmin;PSFmoy;PSFmax;PSFmin;TSFmoy;TSFmax;TSFmin;HREmoy;HREmax;HREmin;TRCmoy;TRCmax;TRCmin;SADmoy;SADmax;SADmin;SALmoy;SALmax;SALmin;AHmoy;AHmax;AHmin|-1|None|True
##QgsProcessingParameterRasterDestination|Output_raster|Enregistrer le paramètre LCZ

library(LCZ4r)
library(terra)


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

# Retrieve the LCZ parameters based on user input
if (iStack==TRUE) {
  Output_raster <- LCZ4r::lcz_get_parameters(LCZ_map, iselect = " ", istack = iStack)
} else {
 Output_raster <- LCZ4r::lcz_get_parameters(LCZ_map, iselect = result_par,istack = FALSE)
} 

#' LCZ_map: Un objet SpatRaster contenant la carte LCZ dérivée des fonctions de téléchargement de la carte LCZ.
#' iStack: Enregistrer plusieurs paramètres raster (ou bandes) comme un seul.
#' Select_parameter: Optionnellement, spécifiez un ou plusieurs noms de paramètres pour récupérer des valeurs spécifiques de moyenne, maximum et minimum :</p><p>
#'             : <b>SVF</b>: Facteur de Vue du Ciel [0-1]. </p><p>
#'             : <b>z0</b>: Classe de Longueur de Rugosité [mètres]. </p><p>
#'             : <b>AR</b>: Rapport d'Aspect [0-3]. </p><p> 
#'             : <b>BSF</b>: Fraction de Surface de Bâtiment [%]. </p><p> 
#'             : <b>ISF</b>: Fraction de Surface Imperméable [%]. </p><p>  
#'             : <b>PSF</b>: Fraction de Surface Perméable [%]. </p><p>  
#'             : <b>TSF</b>: Fraction de Surface d'Arbre [%]. </p><p>  
#'             : <b>HRE</b>: Éléments de Rugosité de Hauteur [mètres]. </p><p>  
#'             : <b>TRC</b>: Classe de Rugosité du Terrain [mètres]. </p><p>
#'             : <b>SAD</b>: Admittance de Surface [J m-2 s1/2 K-1]. </p><p> 
#'             : <b>SAL</b>: Albedo de Surface [0 - 0.5]. </p><p> 
#'             : <b>AH</b>: Sortie de Chaleur Anthropique [W m-2]. </p><p> 
#' Output_raster: 1. Si <b>Enregistrer tous les paramètres comme un seul</b> est TRUE, renvoie tous les paramètres sous forme de pile raster (résolution de 100 m). </p><p>
#'              : 2. Si <b>Enregistrer tous les paramètres comme un seul</b> est FALSE, renvoie le paramètre sélectionné comme un seul raster (résolution de 100 m).
#' ALG_DESC: Cette fonction extrait 12 paramètres physiques de la canopée urbaine LCZ (UCP) basés sur le schéma de classification développé par Stewart et Oke (2012). 
#'         :Pour plus d'informations, visitez : <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_genera_LCZ4r.html#retrieve-and-visualize-lcz-parameters'>Fonctions Générales LCZ (Récupérer et visualiser les paramètres LCZ)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0