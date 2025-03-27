##LCZ4r Fonctions Locales=group
##Analyser l'Intensité de l'Îlot de Chaleur Urbain=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|Entrez la carte LCZ|None
##QgsProcessingParameterFeatureSource|INPUT|Données d'entrée|5
##QgsProcessingParameterField|variable|Colonne de la variable cible|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Colonne d'identification des stations|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Date de début|JJ-MM-AAAA|False
##QgsProcessingParameterString|Date_end|Date de fin|JJ-MM-AAAA|False
##QgsProcessingParameterString|Time_frequency|Fréquence temporelle|heure|False
##QgsProcessingParameterEnum|Impute_missing_values|Imputer les valeurs manquantes|moyenne;médiane;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Method|Sélectionnez la méthode ICU|LCZ;manuel|-1|0|False
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|Afficher stations urbaines et rurales|True
##QgsProcessingParameterEnum|Select_extract_type|Méthode d'extraction|simple;deux.étapes;bilinéaire|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Diviser les données par|année;saison;saisonannée;mois;moisannée;jour.semaine;week-end;heure.été;heure;journée;journée-mois;journée-saison;journée-année|-1|None|True
##QgsProcessingParameterString|Urban_station_reference|Référence station urbaine|None|optional|true
##QgsProcessingParameterString|Rural_station_reference|Référence station rurale|None|optional|true
##QgsProcessingParameterBoolean|display|Visualiser graphique (.html)|True
##QgsProcessingParameterString|Title|Titre|Zones Climatiques Locales|optional|true
##QgsProcessingParameterString|xlab|Étiquette axe x|Temps|optional|true
##QgsProcessingParameterString|ylab|Étiquette axe y|Température de l'air [ºC]|optional|true
##QgsProcessingParameterString|ylab2|Étiquette axe y 2|ICU [ºC]|optional|true
##QgsProcessingParameterString|Caption|Légende|Source : LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Hauteur (pouces)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Largeur (pouces)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Résolution (PPP)|QgsProcessingParameterNumber.Integer|300
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
uhi_methods <- c("LCZ", "manual")
if (!is.null(Method) && Method >= 0 && Method < length(uhi_methods)) {
  result_method <- uhi_methods[Method + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_method <- NULL  
}

#Check extract method type
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
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

# Generate data.frame ----

INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

if (Save_as_plot == TRUE) {
        plot_uhi <- lcz_uhi_intensity(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                        start = formatted_start, end = formatted_end,
                        time.freq = Time_frequency, 
                        by = result_by,
                        extract.method = result_extract,
                        method = result_method,
                        Turban= Urban_station_reference,
                        Trural= Rural_station_reference,
                        group = Group_urban_and_rural_temperatures,
                        impute = result_imputes,
                        iplot = TRUE, 
                        title = Title, caption = Caption, xlab = xlab, ylab = ylab, ylab2 = ylab2)
# Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_uhi,
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
        ggsave(Output, plot_uhi, height = Height, width = Width, dpi = dpi)
    } else {
        tbl_uhi <- lcz_uhi_intensity(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                        time.freq = Time_frequency, 
                        by = result_by,
                        extract.method = result_extract,
                        method = result_method,
                        Turban= Urban_station_reference,
                        Trural= Rural_station_reference,
                        group = Group_urban_and_rural_temperatures,
                        impute = result_imputes, 
                        iplot = FALSE)
        write.csv(tbl_uhi, Output, row.names = FALSE)
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
#' Time_frequency: Résolution temporelle pour la moyenne. Par défaut "heure". Options: "jour", "semaine", "mois" ou "année". Options personnalisées comme "3 jours", "2 semaines", etc.
#' Impute_missing_values: Méthode pour imputer les valeurs manquantes ("moyenne", "médiane", "knn", "bag").
#' Select_extract_type: Méthode d'assignation des classes LCZ. Par défaut "simple". Méthodes disponibles:</p><p>
#'      :1. <b>simple</b>: Assignation basée sur la valeur de la cellule raster. Utilisé dans les réseaux de faible densité.</p><p>
#'      :2. <b>deux.étapes</b>: Assignation des LCZ en filtrant les stations en zones hétérogènes. Requiert ≥80% de pixels concordants dans un noyau 5×5 (Daniel et al., 2017). Réduit le nombre de stations. Pour réseaux ultra et haute densité.</p><p>
#'      :3. <b>bilinéaire</b>: Interpolation des valeurs LCZ à partir des 4 cellules raster les plus proches.</p><p>
#' Split_data_by: Détermine la segmentation des séries temporelles. Options: année, mois, lumière du jour, heure d'été, etc. Combinaisons possibles: lumière-mois, lumière-saison, lumière-année (résolution ≥ "heure").</p><p>
#'              :Détails: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type du package R openair</a>.
#' Method: Méthode de calcul de l'intensité ICU. Options: "LCZ" et "manuel". Avec "LCZ", la fonction identifie automatiquement les types LCZ (LCZ 1-10 pour urbain, LCZ 11-16 pour rural).</p><p>
#'       :Avec "manuel", les utilisateurs sélectionnent des stations de référence.
#' Urban_station_reference: Avec méthode "manuel": sélection de la station urbaine de référence dans la colonne <b>station_id</b>.
#' Rural_station_reference: Avec méthode "manuel": sélection de la station rurale de référence dans la colonne <b>station_id</b>.
#' Group_urban_and_rural_temperatures: Si TRUE, regroupe les températures urbaines et rurales dans le même graphique.
#' display: Si TRUE, affiche le graphique dans le navigateur en HTML.
#' Save_as_plot: Si TRUE sauvegarde un graphique, sinon un dataframe (table.csv). Extensions: .jpeg pour graphiques, .csv pour tableaux.
#' Output: Si Save as plot TRUE: extensions PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Exemple: <b>/Users/myPC/Documents/lcz_uhi.png</b>;</p><p>
#'       :Si FALSE: tableau (.csv). Exemple: <b>/Users/myPC/Documents/lcz_uhi.csv</b>
#' ALG_DESC: Cette fonction calcule l'intensité de l'îlot de chaleur urbain (ICU) basée sur des mesures de température et les Zones Climatiques Locales (LCZ).</p><p>
#'         :Plus d'informations: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_uhi.html'>Fonctions Locales LCZ (Analyse ICU)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>Projet LCZ4r</a>  
#' ALG_VERSION: 0.1.0