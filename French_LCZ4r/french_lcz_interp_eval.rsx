##LCZ4r Fonctions Locales=group
##Évaluer l'Interpolation LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Entrez la carte LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Données d'entrée|5
##QgsProcessingParameterField|variable|Colonne de la variable cible|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Colonne d'identification des stations|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Date de début|JJ-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Date de fin|JJ-MM-AAAA|False
##QgsProcessingParameterBoolean|Select_Anomaly|Évaluer l'anomalie|FALSE
##QgsProcessingParameterBoolean|Select_LOOCV|LOOCV (validation croisée leave-one-out)|True
##QgsProcessingParameterNumber|SplitRatio|Proportion station entraînement/test (si LOOCV faux)|QgsProcessingParameterNumber.Double|0.8
##QgsProcessingParameterEnum|Temporal_resolution|Résolution temporelle|heure;jour;jour.été;semaine;mois;saison;trimestre;année|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Résolution raster|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Modèle de variogramme|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Sélectionnez la méthode d'extraction|simple;deux.étapes;bilinéaire|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Imputer les valeurs manquantes|moyenne;médiane;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|Interpolation LCZ-krigeage|True
##QgsProcessingParameterFileDestination|Output|Enregistrer votre tableau|Fichiers (*.csv)


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


# Generate and plot or data.frame ----
INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

# Check if Hour is an empty string and handle accordingly
    if (LCZ_interpolation) {
        eval_lcz=lcz_interp_eval(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          LOOCV = Select_LOOCV,
                          split.ratio = SplitRatio,
                          Anomaly = Select_Anomaly,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          #by = result_by,
                          impute = result_imputes,
                          LCZinterp = TRUE
                          )
    write.csv(eval_lcz, Output, row.names = FALSE)
    } else {
         Output=lcz_interp_eval(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          sp.res = Raster_resolution,
                          tp.res = result_time,
                          LOOCV = Select_LOOCV,
                          split.ratio = SplitRatio,
                          Anomaly = Select_Anomaly,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          #by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    write.csv(eval_lcz, Output, row.names = FALSE)
    }
 
#' LCZ_map: Un objet <b>SpatRaster</b> dérivé des fonctions <em>Télécharger la carte LCZ</em>.
#' INPUT: Un dataframe (.csv) contenant des données de variables environnementales structurées ainsi:</p><p>
#'      :1. <b>date</b>: Colonne avec informations date-heure. Nommez-la <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Colonne identifiant les stations météorologiques;</p><p>
#'      :3. <b>Variable</b>: Colonne représentant la variable environnementale (ex: température de l'air, humidité relative, précipitation);</p><p>
#'      :4. <b>Latitude et Longitude</b>: Deux colonnes avec coordonnées géographiques. Nommez-les <code style='background-color: lightblue;'>lat|latitude et lon|long|longitude</code>.</p><p>
#'      :Format date-heure: Doit suivre les conventions R, comme <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formats acceptés: "1/2/1999" ou "JJ/MM/AAAA", "1999-02-01".</p><p>
#'      :Plus d'informations: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>données d'exemple</a> 
#' Variable: Nom de la colonne de la variable cible (ex: airT, RH, precip).
#' Station_id: Colonne identifiant les stations météo (ex: station, site, id).
#' Date_start: Date de début au format <b>JJ/MM/AAAA</b>.
#' Date_end: Date de fin dans le même format.
#' Select_Anomaly: Si TRUE, calcule les anomalies. Si FALSE (par défaut), utilise les températures brutes.
#' Select_LOOCV: Si TRUE (par défaut), utilise la validation croisée leave-one-out (LOOCV) pour le krigeage. Si FALSE, utilise la méthode de division en stations d'entraînement et de test.
#' SplitRatio: Valeur numérique représentant la proportion de stations météo utilisées pour l'entraînement (interpolation). Le reste sera utilisé pour les tests (évaluation). Par défaut 0.8 signifie 80% pour l'entraînement et 20% pour les tests.
#' Raster_resolution: Résolution spatiale en mètres pour l'interpolation. Par défaut 100.
#' Temporal_resolution: Résolution temporelle pour la moyenne. Par défaut "heure". Options: "heure", "jour", "jour.été", "semaine", "mois", "trimestre" ou "année".
#' Select_extract_type: Méthode d'assignation des classes LCZ aux stations. Par défaut "simple". Méthodes disponibles:</p><p>
#'      :1. <b>simple</b>: Assignation basée sur la valeur de la cellule raster. Utilisé dans les réseaux de faible densité.</p><p>
#'      :2. <b>deux.étapes</b>: Assignation des LCZ en filtrant les stations en zones hétérogènes. Requiert ≥80% de pixels concordants dans un noyau 5×5 (Daniel et al., 2017). Réduit le nombre de stations. Pour réseaux ultra et haute densité.</p><p>
#'      :3. <b>bilinéaire</b>: Interpolation des valeurs LCZ à partir des 4 cellules raster les plus proches.</p><p>
#' Viogram_model: Si krigeage sélectionné, liste des modèles de variogramme à tester. Par défaut "Sph". Modèles: "Sph", "Exp", "Gau", "Ste" (sphérique, exponentiel, gaussien, famille Matern, Matern, paramétrisation M. Stein).
#' Impute_missing_values: Méthode pour imputer les valeurs manquantes ("moyenne", "médiane", "knn", "bag").
#' LCZ_interpolation: Si TRUE (par défaut), utilise l'approche d'interpolation LCZ. Si FALSE, utilise le krigeage conventionnel sans LCZ.
#' Output: Extension de fichier: tableau (.csv). Exemple: <b>/Users/myPC/Documents/lcz_eval.csv</b>
#' ALG_DESC: Cette fonction évalue la variabilité d'une interpolation spatiale et temporelle d'une variable (ex: température) en utilisant LCZ comme fond. Supporte les méthodes d'interpolation LCZ et conventionnelles. Permet une sélection flexible de période, validation croisée et division des stations pour entraînement et tests.</p><p>
#'         :Plus d'informations: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling_eval.html'>Évaluation d'interpolation basée sur LCZ</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0