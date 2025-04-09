##LCZ4r Fonctions Locales=group
##Calculer les Anomalies LCZ=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Entrez la carte LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Données d'entrée|5
##QgsProcessingParameterField|variable|Colonne de la variable cible|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Colonne d'identification des stations|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Date de début|JJ-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Date de fin|JJ-MM-AAAA|False
##QgsProcessingParameterEnum|Time_frequency|Fréquence temporelle|heure;jour;jour.été;semaine;mois;saison;trimestre;année|-1|0|False
##QgsProcessingParameterString|Select_hour|Spécifier une heure|0:23|optional|True
##QgsProcessingParameterEnum|Select_extract_type|Sélectionnez la méthode d'extraction|simple;deux.étapes;bilinéaire|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Diviser les données par|année;saison;saisonannée;mois;moisannée;jour.semaine;week-end;heure.été;heure;journée;journée-mois;journée-saison;journée-année|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Imputer les valeurs manquantes|moyenne;médiane;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|Sélectionnez le type de graphique|barres_divergentes;barres;points;lollipop|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Choisissez la palette de couleurs|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Égypte;Grec;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Véronèse|-1|0|False
##QgsProcessingParameterString|Title|Titre|Anomalies LCZ|optional|true
##QgsProcessingParameterString|xlab|Étiquette axe x|Stations|optional|true
##QgsProcessingParameterString|ylab|Étiquette axe y|Température de l'air [ºC]|optional|true
##QgsProcessingParameterString|Caption|Légende|Source : LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Nom de légende|Anomalie [ºC]|optional|true
##QgsProcessingParameterNumber|Height|Hauteur du graphique|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largeur du graphique|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Résolution du graphique (PPP)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|display|Visualiser graphique (.html)|True
##QgsProcessingParameterBoolean|Save_as_plot|Enregistrer comme graphique|True
##QgsProcessingParameterFileDestination|Output|Enregistrer l'image|Fichiers PNG (*.png)

library(LCZ4r)
library(sf)
library(ggplot2)
library(terra)
library(lubridate)
library(ggiraph)
library(htmlwidgets)

#Check extract method type
time_options <- c("hour", "day", "DSTday", "week", "month", "season", "quater", "year")
if (!is.null(Time_frequency) && Time_frequency >= 0 && Time_frequency < length(time_options)) {
  result_time <- time_options[Time_frequency + 1]  # Add 1 to align with R's 1-based indexing
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


#Check plot type
plots <- c("diverging_bar", "bar", "dot", "lollipop")
if (!is.null(Select_plot_type) && Select_plot_type >= 0 && Select_plot_type < length(plots)) {
  result_plot <- plots[Select_plot_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_plot <- NULL  # Handle invalid or missing selection
}

#Check color type
colors <- c("VanGogh2", "Archambault", "Cassatt1", "Cassatt2", "Demuth", "Derain", "Egypt", "Greek", "Hiroshige", "Hokusai2", "Hokusai3", "Ingres", "Isfahan1", "Isfahan2", "Java", "Johnson", "Kandinsky", "Morgenstern", "OKeeffe2", "Pillement", "Tam", "Troy", "VanGogh3", "Veronese")
if (!is.null(Palette_color) && Palette_color >= 0 && Palette_color < length(colors)) {
  result_colors <- colors[Palette_color + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_colors <- NULL  # Handle invalid or missing selection
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

    if (grepl(":", Select_hour)) { 
  # Directly convert to numeric range
    Select_hour <- as.numeric(unlist(strsplit(Select_hour, ":")))  # Split and convert to numeric
    Select_hour <- Select_hour[1]:Select_hour[2]  # Create a range from start to end hour
    } else if (grepl(",", Select_hour)) {
    Select_hour <- as.numeric(unlist(strsplit(gsub("c\\(|\\)", "", Select_hour), ",")))
    } else {
    Select_hour <- as.numeric(Select_hour)  # Convert to numeric if not a range
    }
    if (Save_as_plot==TRUE) {
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, hour=Select_hour,
                          time.freq = result_time, 
                          extract.method = result_extract,
                          by = result_by,
                          plot_type=result_plot,
                          impute= result_imputes,
                          legend_name=Legend_name,
                          palette = result_colors,
                          iplot = TRUE, title = Title, caption = Caption, xlab = xlab, ylab = ylab)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
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
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end, hour=Select_hour,
                         time.freq = result_time,
                         extract.method = result_extract,
                         by = result_by,
                         impute = Impute_missing_values, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
} else {
    if (Save_as_plot==TRUE){
        plot_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end, 
                          time.freq = result_time, 
                          extract.method = result_extract,
                          by = result_by,
                          plot_type=result_plot,
                          impute= result_imputes,
                          legend_name=Legend_name,
                          palette = result_colors,
                          iplot = TRUE, title = Title, caption = Caption, xlab = xlab, ylab = ylab)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_ts,
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
        ggsave(Output, plot_ts, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_ts <- lcz_anomaly(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = result_time,
                         extract.method = result_extract,
                         by = result_by,
                         impute = result_imputes, iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
}
 
#' LCZ_map: Un objet <b>SpatRaster</b> dérivé des fonctions <em>Télécharger la carte LCZ</em>.
#' INPUT: Un dataframe (.csv) contenant des données de variables environnementales structurées ainsi:</p><p>
#'      :1. <b>date</b>: Colonne avec informations date-heure. Nommez-la <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Colonne identifiant les stations météorologiques;</p><p>
#'      :3. <b>Variable</b>: Colonne représentant la variable environnementale (ex: température de l'air, humidité relative);</p><p>
#'      :4. <b>Latitude et Longitude</b>: Deux colonnes avec coordonnées géographiques. Nommez-les <code style='background-color: lightblue;'>lat|latitude et lon|long|longitude</code>.</p><p>
#'      :Format date-heure: Doit suivre les conventions R, comme <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> ou <b style='text-decoration: underline;'>2023-03-13</b>. Formats acceptés: "1/2/1999" ou "AAAA-MM-JJ", "1999-02-01".</p><p>
#'      :Plus d'informations: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>données d'exemple</a> 
#' variable: Nom de la colonne de la variable cible (ex: airT, HR).
#' station_id: Colonne identifiant les stations météo (ex: station, site, id).
#' Date_start: Date de début au format <b>JJ-MM-AAAA [01-09-1986]</b>.
#' Date_end: Date de fin dans le même format.
#' Time_frequency: Définit la résolution temporelle pour le calcul des moyennes. Par défaut heure. Résolutions supportées : heure, jour, jour_d'été, semaine, mois, trimestre et année.
#' Select_extract_type: Méthode d'assignation des classes LCZ. Par défaut "simple". Méthodes disponibles:</p><p>
#'      :1. <b>simple</b>: Assignation basée sur la valeur de la cellule raster. Utilisé dans les réseaux de faible densité.</p><p>
#'      :2. <b>deux.étapes</b>: Assignation des LCZ en filtrant les stations en zones hétérogènes. Requiert ≥80% de pixels concordants dans un noyau 5×5 (Daniel et al., 2017). Réduit le nombre de stations. Pour réseaux ultra et haute densité.</p><p>
#'      :3. <b>bilinéaire</b>: Interpolation des valeurs LCZ à partir des 4 cellules raster les plus proches.</p><p>
#' Split_data_by: Détermine la segmentation des séries temporelles. Options: année, mois, lumière du jour, heure d'été, etc. Combinaisons possibles: lumière-mois, lumière-saison, lumière-année (résolution ≥ "heure").</p><p>
#'              :Détails: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type du package R openair</a>.
#' Select_hour: Spécifier une heure ou plage horaire de 0 à 23. Formats possibles:</p><p>
#'      :Plage: 0:12 sélectionne les heures 0 à 12 incluses;</p><p>
#'      :Heures spécifiques: c(1, 6, 18, 21) sélectionne les heures 1, 6, 18 et 21;</p><p>
#'      :Pour des données journalières, mensuelles ou annuelles, laisser ce paramètre vide.
#' Select_plot_type: Choix possibles:</p><p>
#'      :1. <b>barres_divergentes</b>: Diagramme à barres horizontales divergentes depuis le centre (zéro), anomalies positives à droite et négatives à gauche. Idéal pour montrer l'étendue et la direction des anomalies;</p><p>
#'      :2. <b>barres</b>: Diagramme à barres montrant l'amplitude des anomalies par station, colorées selon leur signe. Bon pour comparer les anomalies entre stations;</p><p>
#'      :3. <b>points</b>: Diagramme à points affichant valeurs moyennes et de référence, reliées par des lignes. Taille/couleur des points indique l'amplitude des anomalies. Idéal pour valeurs absolues et anomalies;</p><p>
#'      :4. <b>lollipop</b>: Diagramme lollipop où chaque "bâton" représente une anomalie et les points en haut leur amplitude. Claire visualisation des anomalies positives/négatives.</p><p>
#' Impute_missing_values: Méthode pour imputer les valeurs manquantes: "moyenne", "médiane", "knn", "bag".
#' display: Si TRUE, affiche le graphique dans le navigateur en HTML.
#' Save_as_plot: Si TRUE sauvegarde un graphique, sinon un dataframe (table.csv). Extensions: .jpeg pour graphiques, .csv pour tableaux.
#' Palette_color: Palette de couleurs pour graphiques. Voir <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>package R MetBrewer</a>
#' Output: 1. Si Save as plot TRUE: extensions PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf), SVG (*.svg). Exemple: <b>/Users/myPC/Documents/name_lcz_anomaly.png</b>;</p><p>
#'       :2. Si FALSE: tableau (.csv). Exemple: <b>/Users/myPC/Documents/name_lcz_anomaly.csv</b>
#' ALG_DESC: Cette fonction calcule les anomalies thermiques pour différentes LCZ.</p><p>
#'         :Plus d'informations: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_anomaly.html'>Fonctions Locales LCZ (Anomalies Thermiques)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0