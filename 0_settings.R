library(ggplot2)
library(stringr)

prefixes <- c('D:/azvoleff/Data', # CI-TEAM
              'H:/Data', # Buffalo drive
              'O:/Data', # Blue drive
              '/localdisk/home/azvoleff/Data') # vertica1
prefix <- prefixes[match(TRUE, unlist(lapply(prefixes, function(x) file_test('-d', x))))]

overwrite <- TRUE

sites <- read.csv(file.path(prefix, 'TEAM/Sitecode_Key/sitecode_key.csv'))
sitecodes <- sites$sitecode

product <- 'cru_ts3.22'
datestring <- '1901.2013'

zoi_folder <- file.path(prefix, 'TEAM/ZOI_CSA_PAs')
in_folder <- file.path(prefix, 'CRU/cru_ts_3.22')
out_folder <- file.path(prefix, 'CRU/cru_ts_3.22')
stopifnot(file_test('-d', in_folder))
stopifnot(file_test('-d', out_folder))

datasets <- c('tmn', 'tmx', 'tmp', 'pet', 'dtr', 'pre', 'cld')

# This is the projection of the CRU files
s_srs <- '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0'

width <- 10
height <- 7.5
dpi <- 300
transparent_opts <- theme(legend.position="bottom", 
                          axis.text=element_text(colour='white'), 
                          axis.title.x=element_text(colour='white'), 
                          axis.title.y=element_text(colour='white'), 
                          legend.background=element_rect(fill='transparent', colour=NA),
                          legend.title=element_text(colour='white'), 
                          legend.text=element_text(colour='white'), 
                          plot.background=element_rect(fill='transparent', colour=NA))
