##LCZ4r Lokale Funktionen=group
##Bewerte LCZ-Interpolation=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|LCZ-Karte eingeben|None
##QgsProcessingParameterFeatureSource|INPUT|Eingabedaten|5
##QgsProcessingParameterField|variable|Zielvariablen-Spalte|Tabelle|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Stationen identifizierende Spalte|Tabelle|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Startdatum|TT-MM-JJJJ|False
##QgsProcessingParameterString|Date_end|Enddatum|TT-MM-JJJJ|False
##QgsProcessingParameterBoolean|Select_Anomaly|Anomalie bewerten|FALSE
##QgsProcessingParameterBoolean|Select_LOOCV|LOOCV (Leave-One-Out Kreuzvalidierung)|True
##QgsProcessingParameterNumber|SplitRatio|Trainings-/Testdaten-Aufteilung (wenn LOOCV falsch)|QgsProcessingParameterNumber.Double|0.8
##QgsProcessingParameterEnum|Temporal_resolution|Zeitliche Auflösung|Stunde;Tag;SommerzeitTag;Woche;Monat;Saison;Quartal;Jahr|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Rasterauflösung|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Variogramm-Modell|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Extraktionsmethode auswählen|einfach;zweistufig;bilinear|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Fehlende Werte ersetzen|Mittelwert;Median;knn;bag|-1|None|True
##QgsProcessingParameterBoolean|LCZ_interpolation|LCZ-Kriging-Interpolation|True
##QgsProcessingParameterFileDestination|Output|Tabelle speichern|Dateien (*.csv)


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
 
#' LCZ_map: Ein <b>SpatRaster</b>-Objekt, abgeleitet aus den <em>Download LCZ map</em>-Funktionen.
#' INPUT: Ein Datenrahmen (.csv) mit Umweltvariablendaten, strukturiert wie folgt:</p><p>
#'      :1. <b>date</b>: Eine Spalte mit Datums-/Zeitinformationen. Stellen Sie sicher, dass die Spalte benannt ist als <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Eine Spalte zur Identifizierung von Wetterstationen;</p><p>
#'      :3. <b>Variable</b>: Eine Spalte, die die Umweltvariable darstellt (z.B. Lufttemperatur, relative Luftfeuchtigkeit, Niederschlag);</p><p>
#'      :4. <b>Breiten- und Längengrad</b>: Zwei Spalten mit geografischen Koordinaten. Stellen Sie sicher, dass die Spalten benannt sind als <code style='background-color: lightblue;'>lat|latitude und lon|long|longitude</code>.</p><p>
#'      :Hinweis zur Formatierung: Das Datums-/Zeitformat muss R-Konventionen entsprechen, wie <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> oder <b style='text-decoration: underline;'>2023-03-13</b>. Akzeptierte Formate sind z.B. "1/2/1999" oder "TT/MM/JJJJ", "1999-02-01".</p><p>
#'      :Weitere Informationen: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>Beispieldaten</a> 
#' Variable: Der Name der Zielvariablen-Spalte im Datenrahmen (z.B. airT, RH, precip).
#' Station_id: Die Spalte zur Identifizierung der Wetterstationen (z.B. station, site, id).
#' Date_start: Startdatum für die Analyse im Format <b>TT/MM/JJJJ</b>.
#' Date_end: Enddatum im gleichen Format wie Startdatum.
#' Select_Anomaly: Bei TRUE werden Anomalien berechnet. Bei FALSE (Standard) werden Rohdaten der Lufttemperatur verwendet.
#' Select_LOOCV: Bei TRUE (Standard) wird Leave-One-Out Kreuzvalidierung (LOOCV) für Kriging verwendet. Bei FALSE wird die Aufteilung in Trainings- und Teststationen verwendet.
#' SplitRatio: Ein numerischer Wert, der den Anteil der Wetterstationen für das Training (Interpolation) angibt. Die restlichen Stationen werden für Tests (Evaluation) verwendet. Der Standardwert 0.8 bedeutet, dass 80% der Stationen für Training und 20% für Tests verwendet werden.
#' Raster_resolution: Räumliche Auflösung in Metern für die Interpolation. Standard ist 100.
#' Temporal_resolution: Zeitliche Auflösung für die Mittelwertbildung. Standard ist "Stunde". Unterstützte Auflösungen: "Stunde", "Tag", "SommerzeitTag", "Woche", "Monat", "Quartal" oder "Jahr".
#' Select_extract_type: Methode zur Zuweisung der LCZ-Klasse zu Stationen. Standard ist "einfach". Verfügbare Methoden:</p><p>
#'      :1. <b>einfach</b>: Weist die LCZ-Klasse basierend auf dem Rasterzellenwert zu. Wird in Beobachtungsnetzen mit geringer Dichte verwendet.</p><p>
#'      :2. <b>zweistufig</b>: Weist LCZs zu Stationen zu und filtert solche in heterogenen LCZ-Bereichen heraus. Erfordert ≥80% übereinstimmende Pixel in einem 5×5-Kernel (Daniel et al., 2017). Reduziert die Anzahl der Stationen. Für ultra- und hochdichte Netze.</p><p>
#'      :3. <b>bilinear</b>: Interpoliert LCZ-Werte aus den vier nächsten Rasterzellen.</p><p>
#' Viogram_model: Falls Kriging ausgewählt wird, die Liste der Variogrammmodelle, die getestet und mit Kriging interpoliert werden. Standard ist "Sph". Modelle: "Sph", "Exp", "Gau", "Ste" (sphärisch, exponentiell, gaussisch, Matern-Familie, Matern, M. Steins Parametrisierung).
#' Impute_missing_values: Methode zum Ersetzen fehlender Werte ("Mittelwert", "Median", "knn", "bag").
#' LCZ_interpolation: Bei TRUE (Standard) wird der LCZ-Interpolationsansatz verwendet. Bei FALSE wird konventionelles Kriging ohne LCZ verwendet.
#' Output: Dateierweiterung: Tabelle (.csv). Beispiel: <b>/Users/myPC/Documents/lcz_eval.csv</b>
#' ALG_DESC: Diese Funktion bewertet die Variabilität einer räumlichen und zeitlichen Interpolation einer Variable (z.B. Lufttemperatur) unter Verwendung von LCZ als Hintergrund. Unterstützt sowohl LCZ-basierte als auch konventionelle Interpolationsmethoden. Ermöglicht flexible Zeitraumauswahl, Kreuzvalidierung und Stationsaufteilung für Training und Tests.</p><p>
#'         :Weitere Informationen: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling_eval.html'>Evaluierung LCZ-basierter Interpolation</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r Projekt</a>  
#' ALG_VERSION: 0.1.0