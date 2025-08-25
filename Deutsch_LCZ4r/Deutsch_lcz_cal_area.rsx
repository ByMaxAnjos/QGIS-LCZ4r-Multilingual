##LCZ4r Allgemeine Funktionen=group
##Berechne LCZ-Flächen=display_name
##dont_load_any_packages
##pass_filenames
##QgsProcessingParameterRasterLayer|LCZ_map|LCZ-Karte eingeben|None
##QgsProcessingParameterEnum|Select_plot_type|Diagrammtyp auswählen|Balken;Kreis;Ring|-1|0|False
##QgsProcessingParameterBoolean|display|Diagramm anzeigen (.html)|True
##QgsProcessingParameterString|Title|Titel|Lokale Klimazonen|optional|true
##QgsProcessingParameterString|Subtitle|Untertitel|Meine Stadt|optional|true
##QgsProcessingParameterString|Caption|Beschreibung|Quelle: LCZ4r, 2024.|optional|true
##QgsProcessingParameterString|xlab|x-Achsenbeschriftung|LCZ-Code|optional|true
##QgsProcessingParameterString|ylab|y-Achsenbeschriftung|Fläche [Quadratkilometer]|optional|true
##QgsProcessingParameterBoolean|Show_LCZ_legend|Legende anzeigen|True
##QgsProcessingParameterNumber|Height|Diagrammhöhe|QgsProcessingParameterNumber.Integer|7
##QgsProcessingParameterNumber|Width|Diagrammbreite|QgsProcessingParameterNumber.Integer|10
##QgsProcessingParameterNumber|dpi|Diagrammauflösung (dpi)|QgsProcessingParameterNumber.Integer|300
##QgsProcessingParameterBoolean|Save_as_plot|Als Diagramm speichern|True
##QgsProcessingParameterFileDestination|Output|Bild speichern|


library(LCZ4r)
library(terra)
library(ggiraph)
library(htmlwidgets)

# Load LCZ raster
LCZ_map <- terra::rast(LCZ_map)

# Check plot type selection
plots <- c("bar", "pie", "donut")
if (!is.null(Select_plot_type) && Select_plot_type >= 0 && Select_plot_type < length(plots)) {
  result_plot <- plots[Select_plot_type + 1] # Align with R's 1-based indexing
} else {
  result_plot <- "bar" # Default plot type if input is invalid
}

# Generate and plot LCZ data
if (Save_as_plot) {
    # Calculate areas and create the plot
    plot_lcz <- LCZ4r::lcz_cal_area(
        LCZ_map, 
        plot_type = result_plot,
        iplot = TRUE, 
        show_legend = Show_LCZ_legend,
        title = Title, 
        subtitle = Subtitle, 
        caption = Caption, 
        xlab = xlab, 
        ylab = ylab
    )

    # Plot visualization
    if (display) {
        # Save the interactive plot as an HTML file
    html_file <- file.path(tempdir(), "LCZ4rPlot.html")
    ggiraph::girafe(
    ggobj = plot_lcz,
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

    # Save static plot
    ggplot2::ggsave(Output, plot = plot_lcz, height = Height, width = Width, dpi = dpi)
    
} else {
    # Calculate areas and save as a CSV
    tbl_lcz <- LCZ4r::lcz_cal_area(LCZ_map, iplot = FALSE)
    write.csv(tbl_lcz, Output, row.names = FALSE)
}


#' LCZ_map: Ein SpatRaster-Objekt mit der LCZ-Karte (aus Download LCZ map-Funktionen).
#' Select_plot_type: Diagrammtyp. Optionen: <b>Balken</b>, <b>Kreis</b>, <b>Ring</b> </p><p>
#' display: Bei TRUE wird das Diagramm im Browser als HTML angezeigt.
#' Save_as_plot: Bei TRUE wird das Diagramm gespeichert; sonst eine Tabelle (.csv). Ausgabeformat über Output festlegen (.png/.csv).
#' Show_LCZ_legend: Bei TRUE wird die LCZ-Legende angezeigt.
#' Output: 1. Bei Als Diagramm speichern=TRUE: Dateiendung wählen (z.B. .png, .jpg, .tif, .pdf, .svg). Beispiel: <b>/Users/meinPC/Dokumente/name_lcz_area.png</b>;</p><p>
#'        : 2. Bei Als Diagramm speichern=FALSE: Tabelle als .csv speichern. Beispiel: <b>/Users/meinPC/Dokumente/name_lcz_area.csv</b>
#' ALG_DESC: Berechnet die Flächen der LCZ-Klassen in Prozent und Quadratkilometern.</p><p>
#'          : Mehr Infos: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ4r-Dokumentation</a>
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a>
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r-Projekt</a>
#' ALG_VERSION: 0.1.0

