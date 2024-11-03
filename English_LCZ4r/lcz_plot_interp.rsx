##LCZ4r Local functions=group
##Visualize interpolated map=name
##dont_load_any_packages
##pass_filenames
##Raster_interpolated=raster
##Title_plot=string LCZ interpolation
##Subtitle=string My city
##Legend=string AirT[ºC]
##Caption=string Source:LCZ4r, 2024.
##Height=number 7
##Width=number 10
##dpi=number 300
##Palette_color=enum literal muted;viridi;arid;atlas;bl_yl_rd;deep;gn_yl;high_relieg;pi_y_g;purple;soft muted
##Number_of_columns=number 
##Number_of_rows=number 
##Output=Output File png 

#Load pacakges
library(LCZ4r)
library(ggplot2)

plot_map <- lcz_plot_interp(Raster_interpolated, 
                title = Title_plot, 
                subtitle = Subtitle,
                caption = Caption,
                fill = Legend,
                palette=Palette_color,
                ncol=Number_of_columns,
                nrow=Number_of_rows
                )
ggsave(Output, plot_map, height = Height, width = Width, dpi = dpi)

#' Raster_interpolated: A <b>SpatRaster</b> from <em>Interpolate LCZ functions</em>
#' Palette_color: Gradient palettes available in the: <a href='https://dieghernan.github.io/tidyterra/articles/palettes.html#scale_fill_whitebox_'>tidyterra package</a> 
#' Output: Specifies file extension: PNG (.png), JPG (.jpg .jpeg), TIF (.tif), PDF (*.pdf).</p><p>
#'       :Example: <b>/Users/myPC/Documents/my_interp_map.jpeg</b>
#' ALG_DESC:This function plots the interpolated LCZ anomaly, LCZ air temperature, or other environmental variables.</p><p>
#'         :For more information, visit: <a href='https://bymaxanjos.github.io/LCZ4r/articles/Introd_local_LCZ4r.html#data-inputs'>LCZ local functions</a> 
#' ALG_CREATOR:<a href='https://github.com/ByMaxAnjos'>Max Anjos</a> 
#' ALG_HELP_CREATOR:<a href='https://bymaxanjos.github.io/LCZ4r/index.html'>LCZ4r project</a>  
#' ALG_VERSION: 0.1.0