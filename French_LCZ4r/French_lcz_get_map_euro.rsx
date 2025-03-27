##LCZ4r Fonctions Générales=group
##Télécharger Carte LCZ (Europe)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|City|Nom de la ville|None|optional|true
##QgsProcessingParameterFeatureSource|ROI|Zone d'intérêt|2|None|true
##QgsProcessingParameterRasterDestination|Output|Résultat

library(LCZ4r)
library(sf)
library(terra)

if(City != "") {
Output=LCZ4r::lcz_get_map_euro(city=City)
} else { 
Output=LCZ4r::lcz_get_map_euro(city=NULL, roi = ROI)
}


#' City: Chaîne de caractères spécifiant le nom d'une ville européenne basée sur <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap</a>.</p><p>Exemple : <b>Berlin</b>. Si vide, la ROI personnalisée sera utilisée.  
#' ROI: Optionnel - fournissez une zone d'intérêt (Shapefile ou GeoPackage) pour découper la carte LCZ.  
#' Output: Fichier raster TIFF (100 m de résolution) contenant les classes LCZ 1 à 17.  
#' ALG_DESC: Téléchargez des cartes LCZ européennes. Prend en charge les villes, régions ou formes personnalisées.</p><p>
#'         :Documentation : <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>Fonctions LCZ</a>  
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>  
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0