##LCZ4r Allgemeine Funktionen=group
##LCZ-Karte herunterladen (Generator-Plattform)=display_name
##dont_load_any_packages
##pass_filenames 
##QgsProcessingParameterString|ID|ID du LCZ Factsheet|None|optional|true
##QgsProcessingParameterEnum|Select_band_type|Auswahl des zu verwendenden Merkmals|lczFilter;lcz|-1|0|False
##QgsProcessingParameterRasterDestination|Output|Résultat


library(LCZ4r)
library(sf)
library(terra)

#Check band type
select_band <- c("lczFilter", "lcz")
if (!is.null(Select_band_type) && Select_band_type >= 0 && Select_band_type < length(select_band)) {
  result_band <- select_band[Select_band_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_band <- NULL  
}

Output=LCZ4r::lcz_get_map_generator(ID=ID, band=result_band)

#' ID: Eindeutige ID, generiert von der <a href='https://lcz-generator.rub.de/'>LCZ Generator-Plattform</a>.</p><p>Beispiel (Rio de Janeiro): <b>3110e623fbe4e73b1cde55f0e9832c4f5640ac21</b>
#' Output: TIFF-Rasterdatei (100 m Auflösung) mit LCZ-Klassen 1-17.
#' ALG_DESC: Ruft Local Climate Zone (LCZ)-Karten von der Generator-Plattform ab.</p><p>
#'         :Dokumentation: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ-Funktionen</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r-Projekt</a>
#' ALG_VERSION: 0.1.0