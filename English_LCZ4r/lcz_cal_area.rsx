##LCZ4r General functions=group
##Calculate LCZ areas=display_name
##pass_filenames
##LCZ_map=raster
##Select_plot_type=enum literal bar;pie;donut bar
##Title=string Local Climate Zones
##Subtitle=string My City
##Caption=string Source: LCZ4r, 2024.
##xlab=string LCZ code
##ylab=string Area [square kilometer]
##Show_LCZ_legend=boolean TRUE
##Height=number 7
##Width=number 10
##dpi=number 300
##Save_as_plot=boolean TRUE
##Output=output File png


library(LCZ4r)
library(ggplot2)

# Generate and plot LCZ data
if (Save_as_plot) {
    # Calculate areas and create the plot
    plot_lcz <- lcz_cal_area(
        LCZ_map, 
        iplot = TRUE, 
        plot_type = Select_plot_type, 
        show_legend = Show_LCZ_legend,
        title = Title, 
        subtitle = Subtitle, 
        caption = Caption, 
        xlab = xlab, 
        ylab = ylab
    )
    # Save the plot with the specified DPI and dimensions
    ggsave(Output, plot = plot_lcz, height = Height, width = Width, dpi = dpi)
} else {
    # Calculate areas and output as a data frame
    tbl_lcz <- lcz_cal_area(LCZ_map, iplot = FALSE)
    write.csv(tbl_lcz, Output, row.names = FALSE)
}

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Download LCZ map* functions
#' Select_plot_type: Choose from "bar", "pie", or "donut" to display the LCZ area distribution.
#' Save_as_plot: Set to TRUE to save a plot into your PC; otherwise,  save a data frame (table.csv). Remember to link with Outputs (.jpeg for plot and .csv for table). 
#' Show_LCZ_legend: If TRUE, the plot will include the LCZ legend.
#' Output:1. If Save_as_plot is TRUE, specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf), SVG (*.svg) Example: <b>/Users/myPC/Documents/name_lcz_area.jpeg</b>;</p><p>
#'       :2. if Save_as_plot is FALSE, specifies file extension: table (.csv). Example: <b>/Users/myPC/Documents/name_lcz_area.csv</b>
#' ALG_DESC: This function calculates the areas of LCZ classes in both percentage and square kilometers.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
