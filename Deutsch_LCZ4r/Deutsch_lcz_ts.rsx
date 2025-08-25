##LCZ4r Lokale Funktionen=group
##Analysiere LCZ Zeitreihen = name
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|LCZ-Karte eingeben|None
##QgsProcessingParameterFeatureSource|INPUT|Eingabedaten|5
##QgsProcessingParameterField|variable|Zielvariablen-Spalte|Tabelle|INPUT|-1|False|False
##QgsProcessingParameterField|station_id|Stationen identifizierende Spalte|Tabelle|INPUT|-1|False|False
##QgsProcessingParameterString|Date_start|Startdatum|TT-MM-JJJJ|False
##QgsProcessingParameterString|Date_end|Enddatum|TT-MM-JJJJ|False
##QgsProcessingParameterEnum|Time_frequency|Zeitfrequenz|Stunde;Tag;Sommerzeittag;Woche;Monat;Saison;Quartal;Jahr|-1|0|False
##QgsProcessingParameterEnum|Select_extract_type|Extraktionsmethode auswählen|einfach;zweistufig;bilinear|-1|2|False
##QgsProcessingParameterEnum|Split_data_by|Daten aufteilen nach|Jahr;Saison;SaisonJahr;Monat;MonatJahr;Wochentag;Wochenende;Sommerzeit;Stunde;Tageslicht;Tageslicht-Monat;Tageslicht-Saison;Tageslicht-Jahr|-1|None|True
##QgsProcessingParameterEnum|Impute_missing_values|Fehlende Werte ersetzen|Mittelwert;Median;knn;bag|-1|None|True
##QgsProcessingParameterEnum|Select_plot_type|Diagrammtyp auswählen|einfache_Linie;facettierte_Linie;Heatmap;Erwärmungsstreifen|-1|0|False
##QgsProcessingParameterEnum|Palette_color|Farbpalette auswählen|VanGogh2;Archambault;Cassatt1;Cassatt2;Demuth;Derain;Ägypten;Griechisch;Hiroshige;Hokusai2;Hokusai3;Ingres;Isfahan1;Isfahan2;Java;Johnson;Kandinsky;Morgenstern;OKeeffe2;Pillement;Tam;Troy;VanGogh3;Veronese|-1|0|False
##QgsProcessingParameterBoolean|Smooth_trend_line|Geglättete Trendlinie|False
##QgsProcessingParameterString|Title|Titel|Lokale Klimazonen|optional|true
##QgsProcessingParameterString|xlab|x-Achsenbeschriftung|Zeit|optional|true
##QgsProcessingParameterString|ylab|y-Achsenbeschriftung|Lufttemperatur [°C]|optional|true
##QgsProcessingParameterString|Caption|Bildunterschrift|Quelle: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|Legend_name|Legendenname (nur für Heatmap und Erwärmungsstreifen)|None|optional|true
##QgsProcessingParameterNumber|Height|Diagrammhöhe (Zoll)|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Diagrammbreite (Zoll)|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Auflösung (DPI)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|display|Diagramm anzeigen (.html)|True
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
select_extract <- c("simple", "two.step", "bilinear")
if (!is.null(Select_extract_type) && Select_extract_type >= 0 && Select_extract_type < length(select_extract)) {
  result_extract <- select_extract[Select_extract_type + 1]  # Add 1 to align with R's 1-based indexing
} else {
  result_extract <- NULL  
}

#Check plot type
plots <- c("basic_line", "facet_line", "heatmap", "warming_stripes")
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

# Generate data.frame ----

INPUT$date <-lubridate::as_datetime(INPUT$date)

LCZ_map <- terra::rast(LCZ_map)
LCZ_map <-terra::project(LCZ_map, "+proj=longlat +datum=WGS84 +no_defs")

# Convert to "d/m/y" format
formatted_start <- format(as.Date(Date_start, format = "%d-%m-%Y"), "%d/%m/%Y")
formatted_end <- format(as.Date(Date_end, format = "%d-%m-%Y"), "%d/%m/%Y")

if (Save_as_plot == TRUE) {
        plot_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = INPUT, var = variable, station_id = station_id,
                          start = formatted_start, end = formatted_end,
                          time.freq = Time_frequency,
                          extract.method = result_extract,
                          smooth=Smooth_trend_line,
                          by = result_by,
                          plot_type=result_plot,
                          impute = result_imputes,
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
        tbl_ts <- LCZ4r::lcz_ts(LCZ_map, data_frame = my_table, var = variable, station_id = station_id,
                         start = formatted_start, end = formatted_end,
                         time.freq = Time_frequency,
                         extract.method = result_extract,
                         by = result_by,
                         iplot = FALSE)
        write.csv(tbl_ts, Output, row.names = FALSE)
    }
#' LCZ_map: Ein <b>SpatRaster</b>-Objekt, abgeleitet aus den <em>Download LCZ map</em>-Funktionen.
#' INPUT: Ein Datenrahmen (.csv) mit Umweltvariablendaten, strukturiert wie folgt:</p><p>
#'      :1. <b>date</b>: Eine Spalte mit Datums-/Zeitinformationen. Stellen Sie sicher, dass die Spalte benannt ist als <code style='background-color: lightblue;'>date|time|timestamp|datetime</code>;</p><p>
#'      :2. <b>station</b>: Eine Spalte zur Identifizierung von Wetterstationen;</p><p>
#'      :3. <b>variable</b>: Eine Spalte, die die Umweltvariable darstellt (z.B. Lufttemperatur, relative Luftfeuchtigkeit);</p><p>
#'      :4. <b>Breiten- und Längengrad</b>: Zwei Spalten mit geografischen Koordinaten. Stellen Sie sicher, dass die Spalten benannt sind als <code style='background-color: lightblue;'>lat|latitude und lon|long|longitude</code>.</p><p>
#'      :Hinweis zur Formatierung: Das Datums-/Zeitformat muss R-Konventionen entsprechen, wie <b style='text-decoration: underline;'>2023-03-13 11:00:00</b> oder <b style='text-decoration: underline;'>2023-03-13</b>. Akzeptierte Formate sind z.B. "1/2/1999" oder "YYYY-mm-dd", "1999-02-01".</p><p>
#'      :Weitere Informationen finden Sie in den: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-input-requirements'>Beispieldaten.</a> 
#' variable: Der Name der Zielvariablen-Spalte im Datenrahmen (z.B. airT und RH).
#' station_id: Die Spalte im Datenrahmen zur Identifizierung der Wetterstationen (z.B. station, site, id).
#' Date_start: Startdatum für die Analyse im Format <b>TT-MM-JJJJ [01-09-1986]</b>.
#' Date_end: Enddatum im gleichen Format wie Startdatum.
#' Time_frequency: Definiert die zeitliche Auflösung für Durchschnittsberechnungen. Standardmäßig Stunde. Unterstützte Auflösungen: Stunde, Tag, Sommerzeittag, Woche, Monat, Quartal und Jahr.
#' Select_extract_type: Zeichenkette zur Auswahl der Methode zur Zuweisung der LCZ-Klasse zu jeder Station. Standard ist "einfach". Verfügbare Methoden:</p><p>
#'      :1. <b>einfach</b>: Weist die LCZ-Klasse basierend auf dem Rasterzellenwert zu, in dem der Punkt liegt. Wird oft in Beobachtungsnetzen mit geringer Dichte verwendet.</p><p>
#'      :2. <b>zweistufig</b>: Weist LCZs zu Stationen zu, während solche in heterogenen LCZ-Bereichen herausgefiltert werden. Diese Methode erfordert, dass mindestens 80% der Pixel innerhalb eines 5×5-Kerns mit dem LCZ des Mittelpunkt-Pixels übereinstimmen (Daniel et al., 2017). Diese Methode reduziert die Anzahl der Stationen und wird oft in ultra- und hochdichten Beobachtungsnetzen verwendet.</p><p>
#'      :3. <b>bilinear</b>: Interpoliert die LCZ-Klassenwerte aus den vier nächsten Rasterzellen um den Punkt herum.</p><p>
#' Split_data_by: Bestimmt, wie die Zeitreihe segmentiert wird. Optionen: Jahr, Monat, Tageslicht, Sommerzeit etc. Kombinationen wie Tageslicht-Monat, Tageslicht-Saison oder Tageslicht-Jahr sind möglich (Zeitauflösung muss mindestens "Stunde" sein).</p><p>
#'              :Details unter: <a href='https://bookdown.org/david_carslaw/openair/sections/intro/openair-package.html#the-type-option'>argument type im openair R-Paket</a>.
#' Smooth_trend_line: Optional eine geglättete Trendlinie mit einem Generalisierten Additiven Modell (GAM). Standard ist FALSE.
#' display: Bei TRUE wird das Diagramm im Webbrowser als HTML-Visualisierung angezeigt.
#' Select_plot_type: Diagrammtyp. Optionen:</p><p>
#'      :1. <b>einfache_Linie</b>: Standard-Liniendiagramm</p><p>
#'      :2. <b>facettierte_Linie</b>: Liniendiagramm nach LCZ oder Station unterteilt</p><p>
#'      :3. <b>Heatmap</b>: Wärmekarte der Daten</p><p>
#'      :4. <b>Erwärmungsstreifen</b>: Visualisierung ähnlich Klimaerwärmungsstreifen</p><p>
#' Impute_missing_values: Methode zum Ersetzen fehlender Werte ("Mittelwert", "Median", "knn", "bag").
#' Save_as_plot: Bei TRUE wird die Ausgabe als Diagramm gespeichert, bei FALSE als Tabelle (Dateierweiterungen: .jpeg für Diagramme, .csv für Tabellen).
#' Palette_color: Farbpalette für Diagramme. Weitere Paletten im <a href='https://github.com/BlakeRMills/MetBrewer?tab=readme-ov-file#palettes'>MetBrewer R-Paket</a>
#' Output: 1. Bei Save as plot TRUE: Dateierweiterung PNG (.png), JPG (.jpg .jpeg), TTIF (.tif), PDF (*.pdf), SVG (*.svg);</p><p>
#'       :2. Bei FALSE: Tabelle (.csv)
#' ALG_DESC: Diese Funktion ermöglicht die Analyse von Lufttemperatur oder anderen Umweltvariablen im Zusammenhang mit LCZ über die Zeit.</p><p>
#'         :Anwendungsbeispiele unter: <a href='https://bymaxanjos.github.io/LCZ4r/articles/local_func_time_series.html'>LCZ Lokale Funktionen (Zeitreihenanalyse)</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r Projekt</a>  
#' ALG_VERSION: 0.1.0