##LCZ4r Lokale Funktionen=group
##Karte der LCZ-Anomalie=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|LCZ-Karte eingeben|None
##QgsProcessingParameterFeatureSource|INPUT|Eingabedaten|5
##QgsProcessingParameterField|variable|Zielvariablen-Spalte|Table|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Spalte zur Stationsidentifikation|Table|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Startdatum|TT-MM-JJJJ|False
##QgsProcessingParameterString|Date_end|Enddatum|TT-MM-JJJJ|False
##QgsProcessingParameterString|Select_hour|Bestimmte Stunde angeben|0:23|optional|True
##QgsProcessingParameterEnum|Temporal_resolution|Zeitliche Auflösung|Stunde;Tag;DSTTag;Woche;Monat;Saison;Quartal;Jahr|-1|0|False
##QgsProcessingParameterNumber|Raster_resolution|Rasterauflösung|QgsProcessingParameterNumber.Integer|100
##QgsProcessingParameterEnum|Viogram_model|Variogramm-Modell|Sph;Exp;Gau;Ste|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Extraktionsmethode wählen|einfach;zweistufig;bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Daten aufteilen nach|Jahr;Saison;SaisonJahr;Monat;MonatJahr;Wochentag;Wochenende;dst;Stunde;Tageslicht;Tageslicht-Monat;Tageslicht-Saison;Tageslicht-Jahr|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Fehlende Werte ersetzen|Mittelwert;Median;knn;bag|-1|None|True

##QgsProcessingParameterBoolean|LCZ_interpolation|LCZ-kringing interpolation|True
##QgsProcessingParameterRasterDestination|Output|Save your map


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
        Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
         Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
          Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
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
          Output=lcz_anomaly_map(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          tp.res = result_time,
                          extract.method = result_extract,
                          vg.model = result_methods,
                          by = result_by,
                          impute = result_imputes,
                          LCZinterp = FALSE
                          )
    }
}
 
#' LCZ_map: Ein <b>SpatRaster</b>-Objekt, das aus den <em>Download LCZ map</em>-Funktionen abgeleitet wurde.
#' INPUT: Ein Data Frame (.csv) mit Umweltvariablendaten, strukturiert wie folgt:</p><p>
#'      :1. <b>date</b>: Eine Spalte mit Datums-/Zeitinformationen. Stellen Sie sicher, dass die Spalte <code style='background-color: lightblue;'>date|time|timestamp|datetime</code> heißt;</p><p>
#'      :2. <b>Station</b>: Eine Spalte mit Identifikatoren für Wetterstationen;</p><p>
#'      :3. <b>Variable</b>: Eine Spalte, die die Umweltvariable darstellt (z.B. Lufttemperatur, relative Luftfeuchtigkeit);</p><p>
#'      :4. <b>Breitengrad und Längengrad</b>: Zwei Spalten mit geografischen Koordinaten. Stellen Sie sicher, dass die Spalten <code style='background-color: lightblue;'>lat|latitude und lon|long|longitude</code> heißen.</p><p>
#'      :Hinweis zur Formatierung: Das Datums-/Zeitformat muss R-Konventionen entsprechen, z.B. <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> oder <b style='text-decoration: underline;'>2023-03-13</b>. Auch Formate wie "1/2/1999" oder "TT-MM-JJJJ", "1999-02-01" sind möglich.</p><p>
#'      :Weitere Informationen finden Sie unter: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>Beispieldaten.</a> 
#' variable: Der Name der Zielvariablen-Spalte im Data Frame (z.B. airT, RH, precip).
#' station_id: Die Spalte im Data Frame, die Wetterstationen identifiziert (z.B. station, site, id).
#' Date_start: Startdatum für die Analyse im Format <b>TT/MM/JJJJ</b>. Z.B. 01-09-1986.
#' Date_end: Enddatum, formatiert wie Startdatum.
#' Select_hour: Eine Stunde oder ein Stundenbereich von 0 bis 23. Folgende Formate sind möglich:</p><p>
#'      :Ein Bereich: 0:12 wählt die Stunden 0 bis 12 aus;</p><p>
#'      :Einzelne Stunden: c(1, 6, 18, 21) wählt die Stunden 1, 6, 18 und 21 aus;</p><p>
#'      :Bei täglichen, monatlichen oder jährlichen Daten bleibt dieser Parameter leer.
#' Raster_resolution: Räumliche Auflösung in Metern für die Interpolation. Standard ist 100.
#' Temporal_resolution: Zeitliche Auflösung für die Mittelwertbildung. Standard ist "Stunde". Unterstützte Auflösungen: "Stunde", "Tag", "DSTTag", "Woche", "Monat", "Quartal" oder "Jahr".
#' Select_extract_type: Zeichenkette, die die Methode zur Zuweisung der LCZ-Klasse zu jedem Stationspunkt angibt. Standard ist "einfach". Verfügbare Methoden:</p><p>
#'      :1. <b>einfach</b>: Weist die LCZ-Klasse basierend auf dem Rasterzellenwert zu, in dem der Punkt liegt. Wird oft in Beobachtungsnetzen mit geringer Dichte verwendet.</p><p>
#'      :2. <b>zweistufig</b>: Weist LCZs zu Stationen zu, während solche in heterogenen LCZ-Bereichen herausgefiltert werden. Erfordert, dass mindestens 80% der Pixel innerhalb eines 5×5-Kerns mit dem LCZ des Mittelpunktes übereinstimmen (Daniel et al., 2017). Reduziert die Anzahl der Stationen.</p><p>
#'      :3. <b>bilinear</b>: Interpoliert die LCZ-Klassenwerte aus den vier nächsten Rasterzellen um den Punkt.</p><p>
#' Split_data_by: Bestimmt, wie die Zeitreihe segmentiert wird. Optionen: Jahr, Monat, Tageslicht, dst (Sommerzeit), wd (Windrichtung) usw. "Tageslicht" teilt Daten in Tages- und Nachtperioden.</p><p>
#'              :Kombinationen möglich: Tageslicht-Monat, Tageslicht-Saison oder Tageslicht-Jahr (Time_resolution muss mindestens "Stunde" sein).</p><p>
#'              :Details unter: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type im openair R-Paket</a>.
#' Viogram_model: Falls Kriging gewählt wird, Liste der Variogrammmodelle, die getestet werden. Standard ist "Sph". Modelle: "Sph" (sphärisch), "Exp" (exponentiell), "Gau" (gaußsch), "Ste" (Matern-Familie, Steinsche Parametrisierung).
#' Impute_missing_values: Methode zur Schätzung fehlender Werte ("Mittelwert", "Median", "knn", "bag").
#' LCZ_interpolation: Wenn TRUE (Standard), wird die LCZ-Interpolation verwendet. Bei FALSE konventionelle Interpolation ohne LCZ.
#' Output: Ein Raster im terra GeoTIF-Format.
#' ALG_DESC: Diese Funktion erzeugt eine grafische Darstellung thermischer Anomalien für verschiedene Lokale Klimazonen (LCZs).</p><p>
#'         :Weitere Informationen: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_modeling.html#interpolating-thermal-anomalies-with-lcz'>LCZ Lokale Funktionen (Interpolation thermischer Anomalien mit LCZ)</a> 
#' ALG_CREATOR: <a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR: <a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r Projekt</a>  
#' ALG_VERSION: 0.1.0