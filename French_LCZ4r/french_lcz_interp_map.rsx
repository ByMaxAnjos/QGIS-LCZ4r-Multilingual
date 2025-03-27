##LCZ4r Fonctions Locales=group
##Carte de Température de l'Air LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Entrez la carte LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Données d'entrée|5
##QgsProcessingParameterField|variable|Colonne de la variable cible|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Colonne d'identification des stations|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Date de début|JJ-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Date de fin|JJ-MM-AAAA|False
##QgsProcessingParameterString|Select_hour|Spécifier une heure|0:23|optional|True
##QgsProcessingParameterEnum|Temporal_resolution|Résolution temporelle|heure;jour;jourDST;semaine;mois;saison;trimestre;année|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Résolution raster|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Modèle de variogramme|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Sélectionner la méthode d'extraction|simple;deux.étapes;bilinéaire|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Diviser les données par|année;saison;saisonAnnée;mois;moisAnnée;jourSemaine;week-end;dst;heure;lumJour;lumJour-mois;lumJour-saison;lumJour-année|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Imputer les valeurs manquantes|moyenne;médiane;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|Interpolation LCZ-krigeage|True
##QgsProcessingParameterRasterDestination|Output|Enregistrer votre carte

library(LCZ4r)
library(ggplot2)
library(terra)
library(lubridate)


#Check extract method type
time_options <- c("hour", "day", "DSTday", "week", "month", "season", "quater", "year")
if (!is.null(Temporal_resolution) && Temporal_resolution >= 0 && Temporal_resolution < length(time_options)) {
  result_time <- time_options[Temporal_resolution + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_time <- NULL  
}

#Check extract method type
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
}

#Check method type
methods <- c("Sph", "Exp", "Gau", "Ste")
if (!is.null(Viogram_model) && Viogram_model >= 0 && Viogram_model < length(methods)) {
  result_methods <- methods[Viogram_model + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_methods <- NULL  # Handle invalid or missing selection
}

#Check impute missing values
imputes <- c("mean", "median", "knn", "bag")
if (!is.null(Impute_missing_values) && Impute_missing_values >= 0 && Impute_missing_values < length(imputes)) {
  result_imputes <- imputes[Impute_missing_values + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_imputes <- NULL  # Handle invalid or missing selection
}

# Check for date conditions by
type_by <- c("year","season", "seasonyear", "month", "monthyear","weekday", "weekend", "dst", "hour", "daylight", "daylight-month", "daylight-season", "daylight-year")
if (!is.null(Split_data_by) && Split_data_by >= 0 && Split_data_by < length(type_by)) {
  result_by <- type_by[Split_data_by + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_by <- NULL  # Handle invalid or missing selection
}

if ("daylight-month" %in% result_by) {
    result_by <- c("daylight", "month")
}
if ("daylight-season" %in% result_by) {
    result_by <- c("daylight", "season")
}
if ("daylight-year" %in% result_by) {
    result_by <- c("daylight", "year")
}

# Generate and plot or data.frame ----
INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

# Check if Hour is an empty string and handle accordingly
if(Select_hour != "") { 
   # Check if Hour contains a colon and split accordingly
    if (grepl(":", Select_hour)) { 
  # Directly convert to numeric range
    Select_hour <- as.numeric(unlist(strsplit(Select_hour, ":")))  # Split and convert to numeric
    Select_hour <- Select_hour[1]:Select_hour[2]  # Create a range from start to end hour
    } else if (grepl(",", Select_hour)) {
    Select_hour <- as.numeric(unlist(strsplit(gsub("c\\(|\\)", "", Select_hour), ",")))
    } else {
    Select_hour <- as.numeric(Select_hour)  # Convert to numeric if not a range
    }
    if (LCZ_interpolation) {
        Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
         Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
} else {
    if (LCZ_interpolation){
          Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    } else {
          Output=lcz_interp_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
}
 
#' LCZ_map: Un objet <b>SpatRaster</b> dérivé des fonctions <em>Télécharger la carte LCZ</em>.
#' INPUT: Un dataframe (.csv) contenant des données de variables environnementales structurées comme suit:</p><p>
#'      :1. <b>date</b>: Une colonne avec des informations date-heure. Nommez la colonne <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Une colonne spécifiant les identifiants des stations météorologiques;</p><p>
#'      :3. <b>Variable</b>: Une colonne représentant la variable environnementale (ex: température de l'air, humidité relative);</p><p>
#'      :4. <b>Latitude et Longitude</b>: Deux colonnes fournissant les coordonnées géographiques. Nommez les colonnes <code style='background-color: lightblue;'>lat|latitude et lon|long|longitude</code>.</p><p>
#'      :Note de format: Le format date-heure doit suivre les conventions R, comme <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formats acceptés: "1/2/1999" ou "AAAA-MM-JJ", "1999-02-01".</p><p>
#'      :Plus d'infos: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>données exemples</a>.
#' Variable: Nom de la colonne de la variable cible (ex: airT, RH, precip).
#' Station_id: Colonne identifiant les stations météorologiques (ex: station, site, id).
#' Date_start: Date de début au format <b>JJ-MM-AAAA [01-09-1986]</b>.
#' Date_end: Date de fin, même format que Date_start.
#' Select_hour: Spécifie une heure ou une plage horaire de 0 à 23. Formats possibles:</p><p>
#'      :Plage: 0:12 sélectionne les heures 0 à 12;</p><p>
#'      :Heures spécifiques: c(1, 6, 18, 21) pour les heures 1, 6, 18 et 21;</p><p>
#'      :Laissez vide pour des données journalières/mensuelles/annuelles.
#' Raster_resolution: Résolution spatiale en mètres pour l'interpolation. Par défaut: 100.
#' Temporal_resolution: Résolution temporelle pour la moyenne. Par défaut: "heure". Options: "heure", "jour", "jourDST", "semaine", "mois", "trimestre" ou "année".
#' Select_extract_type: Méthode d'assignation des classes LCZ aux stations. Par défaut: "simple". Méthodes:</p><p>
#'      :1. <b>simple</b>: Assignation basée sur la valeur de la cellule raster. Utilisé dans les réseaux de faible densité.</p><p>
#'      :2. <b>deux.étapes</b>: Filtre les stations en zones LCZ hétérogènes. Requiert ≥80% de pixels concordants dans un noyau 5×5 (Daniel et al., 2017). Réduit le nombre de stations. Pour réseaux denses.</p><p>
#'      :3. <b>bilinéaire</b>: Interpole les valeurs LCZ des 4 cellules raster les plus proches.</p><p>
#' Split_data_by: Segmentation des séries temporelles. Options: année, mois, lumière du jour, dst (heure d'été), wd (direction du vent) etc. "lumière du jour" sépare les données en périodes diurnes/nocturnes.</p><p>
#'              :Combinaisons possibles: lumière du jour-mois, lumière du jour-saison, lumière du jour-année (Time_resolution doit être "heure").</p><p>
#'              :Détails: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type du package R openair</a>.
#' Viogram_model: Si krigeage activé, liste des modèles de variogramme testés. Par défaut: "Sph". Modèles: "Sph" (sphérique), "Exp" (exponentiel), "Gau" (gaussien), "Ste" (famille Matern, paramétrisation de Stein).
#' Impute_missing_values: Méthode d'imputation des valeurs manquantes ("moyenne", "médiane", "knn", "bag").
#' LCZ_interpolation: Si TRUE (défaut), utilise l'interpolation LCZ. Si FALSE, krigeage conventionnel sans LCZ.
#' Output: Raster au format GeoTIF de terra.
#' ALG_DESC: Interpolation spatiale de température (ou autre variable) utilisant LCZ et krigeage.</p><p>
#'         :Plus d'infos: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling.html'>Fonctions Locales LCZ (Modélisation de Température avec LCZ)</a>.
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a>.
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>.
#' ALG_VERSION: 0.1.0