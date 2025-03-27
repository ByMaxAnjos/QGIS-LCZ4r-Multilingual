##LCZ4r Allgemeine Funktionen=group
##LCZ-Karte herunterladen (Global)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|City|Stadtname|None|optional|true
##QgsProcessingParameterFeatureSource|ROI|Interessensgebiet|2|None|true
##QgsProcessingParameterRasterDestination|Output|Ergebnis

library(LCZ4r)
library(terra)
library(sf)

if(City != "") {
Output=lcz_get_map(city=City)
} else { 
Output=lcz_get_map(city=NULL, roi = ROI)
}


#' City: Name der Zielstadt oder -region basierend auf <a href='https://nominatim.openstreetmap.org/ui/search.html'>OpenStreetMap</a>.</p><p>Beispiel: <b>Rio de Janeiro</b>. Falls leer, wird benutzerdefinierte ROI verwendet.
#' ROI: Optional - Geben Sie ein Interessensgebiet (Shapefile/GeoPackage) zum Zuschneiden der LCZ-Karte an.
#' Output: TIFF-Rasterdatei (100 m Auflösung) mit LCZ-Klassen 1-17.
#' ALG_DESC: Lädt LCZ-Karten aus globaler Datenbank herunter. Unterstützt Städte oder benutzerdefinierte Regionen.</p><p>
#'         :Dokumentation: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ-Funktionen</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r-Projekt</a>
#' ALG_VERSION: 0.1.0
