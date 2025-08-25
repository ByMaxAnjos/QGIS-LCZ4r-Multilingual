##LCZ4r Lokale Funktionen=group
##Analysiere städtische Wärmeinsel-Intensität=name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|LCZ-Karte eingeben|None
##QgsProcessingParameterFeatureSource|INPUT|Eingabedaten|5
##QgsProcessingParameterField|variable|Zielvariablen-Spalte|Tabelle|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Stationen identifizierende Spalte|Tabelle|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Startdatum|TT-MM-JJJJ|False
##QgsProcessingParameterString|Date_end|Enddatum|TT-MM-JJJJ|False
##QgsProcessingParameterEnum|Time_frequency|Zeitfrequenz|Stunde;Tag;Sommerzeittag;Woche;Monat;Saison;Quartal;Jahr|-1|0|False
##QgsProcessingParameterEnum|Impute_missing_values|Fehlende Werte ersetzen|Mittelwert;Median;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Method|Wählen Sie die UHI-Methode|LCZ;manuell|-1|0|False
##QgsProcessingParameterBoolean|Group_urban_and_rural_temperatures|Zeige städtische und ländliche Stationen|True
##QgsProcessingParameterEnum|Select_extract_type|Extraktionsmethode auswählen|einfach;zweistufig;bilinear|-1|0|False
##QgsProcessingParameterEnum|Split_data_by|Daten aufteilen nach|Jahr;Saison;SaisonJahr;Monat;MonatJahr;Wochentag;Wochenende;Sommerzeit;Stunde;Tageslicht;Tageslicht-Monat;Tageslicht-Saison;Tageslicht-Jahr|-1|None|True
##QgsProcessingParameterString|Urban_station_reference|Referenz für städtische Station|None|optional|true
##QgsProcessingParameterString|Rural_station_reference|Referenz für ländliche Station|None|optional|true
##QgsProcessingParameterBoolean|display|Diagramm anzeigen (.html)|True
##QgsProcessingParameterString|Title|Titel|Lokale Klimazonen|optional|true
##QgsProcessingParameterString|xlab|x-Achsenbeschriftung|Zeit|optional|true
##QgsProcessingParameterString|ylab|y-Achsenbeschriftung|Lufttemperatur [ºC]|optional|true
##QgsProcessingParameterString|ylab2|y-Achsenbeschriftung 2|UHI [ºC]|optional|true
##QgsProcessingParameterString|Caption|Bildunterschrift|Quelle: LCZ4r, 2024.|optional|true
##QgsProcessingParameterNumber|Height|Diagrammhöhe (Zoll)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Diagrammbreite (Zoll)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Auflösung (DPI)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Als Diagramm speichern|True
##QgsProcessingParameterFileDestination|Output|Bild speichern|

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
                        time.freq = result_time, 
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
                        time.freq = result_time, 
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

#' LCZ_map: Ein <b>SpatRaster</b>-Objekt, abgeleitet aus den <em>Download LCZ map</em>-Funktionen.
#' INPUT: Ein Datenrahmen (.csv) mit Umweltvariablendaten, strukturiert wie folgt:</p><p>
#'      :1. <b>date</b>: Eine Spalte mit Datums-/Zeitinformationen. Stellen Sie sicher, dass die Spalte benannt ist als <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>Station</b>: Eine Spalte zur Identifizierung von Wetterstationen;</p><p>
#'      :3. <b>Variable</b>: Eine Spalte, die die Umweltvariable darstellt (z.B. Lufttemperatur, relative Luftfeuchtigkeit);</p><p>
#'      :4. <b>Breiten- und Längengrad</b>: Zwei Spalten mit geografischen Koordinaten. Stellen Sie sicher, dass die Spalten benannt sind als <code style='background-color: lightblue;'>lat|latitude und lon|long|longitude</code>.</p><p>
#'      :Hinweis zur Formatierung: Das Datums-/Zeitformat muss R-Konventionen entsprechen, wie <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> oder <b style='text-decoration: underline;'>2023-03-13</b>. Akzeptierte Formate sind z.B. "1/2/1999" oder "JJJJ-MM-TT", "1999-02-01".</p><p>
#'      :Weitere Informationen: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>Beispieldaten</a> 
#' variable: Der Name der Zielvariablen-Spalte im Datenrahmen (z.B. airT, HR).
#' station_id: Die Spalte zur Identifizierung der Wetterstationen (z.B. station, site, id).
#' Date_start: Startdatum für die Analyse im Format <b>TT-MM-JJJJ [01-09-1986]</b>.
#' Date_end: Enddatum im gleichen Format wie Startdatum.
#' Time_frequency: Definiert die zeitliche Auflösung für Durchschnittsberechnungen. Standardmäßig Stunde. Unterstützte Auflösungen: Stunde, Tag, Sommerzeittag, Woche, Monat, Quartal und Jahr.
#' Impute_missing_values: Methode zum Ersetzen fehlender Werte ("Mittelwert", "Median", "knn", "bag").
#' Select_extract_type: Methode zur Zuweisung der LCZ-Klasse zu Stationen. Standard ist "einfach". Verfügbare Methoden:</p><p>
#'      :1. <b>einfach</b>: Weist die LCZ-Klasse basierend auf dem Rasterzellenwert zu. Wird in Beobachtungsnetzen mit geringer Dichte verwendet.</p><p>
#'      :2. <b>zweistufig</b>: Weist LCZs zu Stationen zu und filtert solche in heterogenen LCZ-Bereichen heraus. Erfordert ≥80% übereinstimmende Pixel in einem 5×5-Kernel (Daniel et al., 2017). Reduziert die Anzahl der Stationen. Für ultra- und hochdichte Netze.</p><p>
#'      :3. <b>bilinear</b>: Interpoliert LCZ-Werte aus den vier nächsten Rasterzellen.</p><p>
#' Split_data_by: Bestimmt die Segmentierung der Zeitreihe. Optionen: Jahr, Monat, Tageslicht, Sommerzeit etc. Kombinationen wie Tageslicht-Monat, Tageslicht-Saison oder Tageslicht-Jahr (Zeitauflösung ≥ "Stunde").</p><p>
#'              :Details: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type im openair R-Paket</a>.
#' Method: Methode zur Berechnung der UHI-Intensität. Optionen: "LCZ" und "manuell". Bei "LCZ" identifiziert die Funktion automatisch LCZ-Bebauungstypen (LCZ 1-10 für städtische, LCZ 11-16 für ländliche Temperaturen).</p><p>
#'       :Bei "manuell" können Benutzer Referenzstationen auswählen.
#' Urban_station_reference: Bei "manuell"-Methode: Auswahl der städtischen Referenzstation in der <b>station_id</b>-Spalte.
#' Rural_station_reference: Bei "manuell"-Methode: Auswahl der ländlichen Referenzstation in der <b>station_id</b>-Spalte.
#' Group_urban_and_rural_temperatures: Bei TRUE werden städtische und ländliche Temperaturen im gleichen Diagramm gruppiert.
#' display: Bei TRUE wird das Diagramm im Browser als HTML angezeigt.
#' Save_as_plot: Bei TRUE wird ein Diagramm gespeichert, sonst ein Datenrahmen (table.csv). Ausgabedateien: .jpeg für Diagramme, .csv für Tabellen.
#' Output: Bei Save as plot TRUE: Dateierweiterungen PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Beispiel: <b>/Users/myPC/Documents/lcz_uhi.png</b>;</p><p>
#'       :Bei FALSE: Tabelle (.csv). Beispiel: <b>/Users/myPC/Documents/lcz_uhi.csv</b>
#' ALG_DESC: Diese Funktion berechnet die Intensität der städtischen Wärmeinsel (UHI) basierend auf Lufttemperaturmessungen und Lokalen Klimazonen (LCZ).</p><p>
#'         :Weitere Informationen: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_uhi.html'>LCZ Lokale Funktionen (UHI-Analyse)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r Projekt</a>  
#' ALG_VERSION: 0.1.0