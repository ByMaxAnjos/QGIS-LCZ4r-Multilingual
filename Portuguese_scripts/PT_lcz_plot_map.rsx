##PT-LCZ4r Funções Gerais=group
##Visualizar mapa LCZ=display_name
##dont_load_any_packages
##pass_filenames
##LCZ_map=raster
##Title=string Local Climate Zones
##Subtitle=string My City
##Caption=string Source:LCZ4r,  2024.
##Height=number 7
##Width=number 10
##dpi=number 300
##inclusive=boolean FALSE
##Output=output File

library(LCZ4r)
library(ggplot2)

# Generate and plot the LCZ map
plot_lcz<-lcz_plot_map(LCZ_map, title = Title, subtitle=Subtitle, caption = Caption, inclusive=inclusive)
ggsave(Output, plot_lcz, height = Height, width = Width, dpi=dpi)

#' LCZ_map: A SpatRaster object containing the LCZ map derived from lcz_get_map* functions
#' inclusive: Logical. Set to TRUE to use a colorblind-friendly palette.
#' Output: Specifies file extensions: PNG (*.png), JPG (*.jpg *.jpeg), TIF (*.tif), PDF (*.pdf).
#' ALG_DESC: This function generates a graphical representation of a Local Climate Zone (LCZ) map provided as a SpatRaster object.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_general_LCZ4r.html'>LCZ general functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0