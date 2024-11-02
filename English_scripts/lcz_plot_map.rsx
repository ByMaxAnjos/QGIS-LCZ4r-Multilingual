##LCZ4r General functions=group
##Visualize LCZ map=display_name
##dont_load_any_packages
##pass_filenames
##LCZ_map=raster
##Title=string Local Climate Zones
##Subtitle=string My City
##Caption=string Source: LCZ4r, 2024.
##Show_LCZ_legend=boolean TRUE
##Height=number 7
##Width=number 10
##dpi=number 300
##inclusive=boolean FALSE
##Output=output File png

if(!require(LCZ4r)) remotes::install_github("ByMaxAnjos/LCZ4r", upgrade = "never")
if(!require(LCZ4r)) install.packages("data.table")


library(LCZ4r)
library(ggplot2)

# Generate and plot the LCZ map
plot_lcz<-lcz_plot_map(LCZ_map, 
            show_legend=Show_LCZ_legend,
            title = Title, 
            subtitle=Subtitle, 
            caption = Caption, 
            inclusive=inclusive)
ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)

#' LCZ_map: A SpatRaster object containing the LCZ map derived from Obtain LCZ map* functions
#' Show_LCZ_legend: If TRUE, the plot will include the LCZ legend.
#' inclusive: Logical. Set to TRUE to use a colorblind-friendly palette.
#' Output: Specifies file extensions: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf), SVG (*.svg).</p><p>
#'       : Example: <b>/Users/myPC/Documents/name_lcz_map.jpeg</b>
#' ALG_DESC: This function generates a graphical representation of a Local Climate Zone (LCZ) map.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0
