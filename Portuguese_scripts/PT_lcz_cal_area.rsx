##PT-LCZ4r Funções Gerais=group
##Calcular areas LCZ=display_name
##pass_filenames
##LCZ_map=raster
##Title=string Local Climate Zones
##Subtitle=string My City
##Caption=string Source: LCZ4r,  2024.
##xlab=string LCZ code
##ylab=string Area [square kilometer]
##dpi=number 300
##inclusive=boolean FALSE
##iPlot=boolean TRUE
##Output=output File


library(LCZ4r)
library(ggplot2)

# Generate and plot or data.frame ----
if (iPlot) {
    plot_lcz <- lcz_cal_area(LCZ_map, iplot = TRUE, title = Title, subtitle = Subtitle, caption = Caption, xlab = xlab, ylab = ylab)
    ggsave(Output, plot_lcz, height = 8, width = 12, dpi = dpi)
} else {
    tbl_lcz <- lcz_cal_area(LCZ_map, iplot = FALSE)
    write.csv(tbl_lcz, Output, row.names = FALSE)
}

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Obtain LCZ map from* functions
#' inclusive: Logical. Set to TRUE to use a colorblind-friendly palette.
#' iPlot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs (e.g., .jpeg for plot and .csv for table). 
#' Output:1. If iPlot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf). Example: <b>/Users/myPC/Documents/lcz_ts.jpeg</b>;</p><p>
#'       :2. if iPlot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/lcz_ts.csv</b>
#' ALG_DESC: This function calculates the areas of LCZ classes in both percentage and square kilometers.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0