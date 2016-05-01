require(dplyr)
require(data.table)
require(yaml)
require(viridis)
require(R.utils)
source('settlefunc.r')

options(warn=-1)

vircols <- viridis::viridis(250)
# define analogue of matlabs repmat function
repmat = function(X,m=1,n=1){
  ##R equivalent of repmat (matlab)
  mx = dim(X)[1]
  nx = dim(X)[2]
  matrix(t(matrix(X,mx,nx*n)),mx*m,nx*n,byrow=T)
}

# geodesic distance - vectorised for speed
geodesic.distance <- function(point1, point2) 
{ 
  R <- 6371 
  p1rad <- point1 * pi/180 
  p2rad <- point2 * pi/180 
  d <- (sin(p1rad[,2]) %o% sin(p2rad[,2]))+(cos(p1rad[,2]) %o% cos(p2rad[,2])) * cos(abs(outer(p2rad[,1],p1rad[,1],'-')))	
  d <- acos(d) 
  d[is.nan(d)] <- 0
  R*d 
} 

# read post processing config
yaml.config <- "process.yaml"
parm <- yaml.load_file(yaml.config)

# unzip outputs into temp folder
gunzip(paste0('outputs/',parm$output,'-outputs.tar.gz'), remove =F, overwrite=T)
untar(paste0('outputs/',parm$output,'-outputs.tar'), exdir = 'tempdir',)

# copy gerris control file
mkdirs(paste0('outputs/',parm$output,'/'))
file.copy('tempdir/run/output/Cook.yaml',paste0('outputs/',parm$output,'/'))

# load gerris control config
ctrl <- yaml.load_file(paste0('outputs/',parm$output,'/Cook.yaml'))
              
# build particle files table             
files <- dir('tempdir/run/output/')
files <- files[grepl('.dat',files)]
cloudy <- do.call(rbind,strsplit(files,'-'))
cloudy[,2] <- as.numeric(do.call(rbind,strsplit(cloudy[,2],'\\.'))[,1])
cloudy <- data.frame(cloudy)
colnames(cloudy) <- c('cloud','t')

# particle cloud names and parameters
cloudnames <- unique(cloudy$cloud)
regionames <- unlist(lapply(ctrl$Regions,function(x) x$RegionName))

# get competency and swimming function from closure
comp_pars <- parm$compfunc
swim_pars <- parm$swimfunc

cfunc <- compfunc(comp_pars$type)
sfunc <- swimfunc(swim_pars$type)

# plot competency
lapply(regionames, function(cl){
# get competency given parameters
  this_comp_par <- ctrl$Regions[[which(!is.na(sapply(regionames,grep,cl)>0))]]
  cprob <- cfunc(
    pars = comp_pars,
    int  = this_comp_par$outputInterval,
    tmin = this_comp_par$start,
    tmax = this_comp_par$start+this_comp_par$duration
  )
  
 mkdirs(paste0('outputs/',parm$output,'/',cl))
 pdf(paste0('outputs/',parm$output,'/',cl,'/Competency.pdf'))
 plot(x= seq(this_comp_par$start,
          this_comp_par$start+this_comp_par$duration,
          this_comp_par$outputInterval)/3600,
      y= cprob, 
      xlab = 'Time (h)',
      ylab = 'Fraction alive and competent',
      type='line')
  dev.off()
  
  sprob <- sfunc(dists = 1:swim_pars$maxPlotDist,
                 pars = swim_pars)
  
  pdf(paste0('outputs/',parm$output,'/',cl,'/Swimming.pdf'))
  plot(x= 1:swim_pars$maxPlotDist,
       y= sprob, 
       xlab = 'Distance (m)',
       ylab = 'Settlement probability',
       type='line')
  dev.off()
  
  CM
  
})

### get connectivity matrix for each release ---
CM <- list()
for (cl in cloudnames) {

    # read filenames for release
    this.cl <- cloudy %>% filter(cloud == cl) %>% arrange(t)
    files <- paste0('tempdir/run/output/',apply(this.cl,1,paste, collapse='-'),'.dat')
    
    # get competency given parameters
    this_comp_par <- ctrl$Regions[[which(!is.na(sapply(regionames,grep,cl)>0))]]
    cprob <- cfunc(
          pars = comp_pars,
          int  = this_comp_par$outputInterval,
          tmin = this_comp_par$start,
          tmax = this_comp_par$start+this_comp_par$duration
          )
    
    mkdirs(paste0('outputs/',parm$output,'/',cl))
    
    # read files
    clouds <- lapply(files, fread, skip=0, select=1:4, 
                     colClasses=c('numeric', 'numeric', 'numeric', 'numeric'), 
                     nrows=R.utils::countLines(files[1])-3)

    origin <- as.data.frame(clouds[[1]])
    names(origin) <- c('id','long','lat','depth')
    n <- nrow(origin)
    frac <- matrix(1,n,1)
    CM[[cl]] <- matrix(0,n,n)
    clouds <- clouds[-1]

    # settlement fractions at each time
    for (tcix in 1:length(clouds)) {
      tc <- as.data.frame(clouds[[tcix]])
      names(tc) <- c('id','long','lat','depth')
      #this does that
      dists <- geodesic.distance(tc[,c('long','lat')],
                                 origin[,c('long','lat')])
      
      sprob <- sfunc(dists = dists,
            pars = swim_pars)
      tprob <-  sprob * (cprob[tcix+1])/n
      CM[[cl]]   <- CM[[cl]] + repmat(frac,m=1,n=n)*tprob
      frac <- frac*(1-rowSums(tprob))
    }    
    
    png(paste0('outputs/',parm$output,'/',cl,'/Connectivity.png'))
    image(CM[[cl]], col = vircols,
          xlab = 'Destination sites', 
          ylab='Origin sites',
          tick=F)
    dev.off()
    
    this.CM <- CM[[cl]]
    save(this.CM,file=paste0('outputs/',parm$output,'/',cl,'/Connectivity.Rdata'))
    write.csv(this.CM,file=paste0('outputs/',parm$output,'/',cl,'/Connectivity.csv'))
    
    }


# plot competency
lapply(regionames, function(cl){
  # get competency given parameters
  ix <- grep(cl,names(CM))
  CM.reg <- do.call('+',CM[ix])
  
  mkdirs(paste0('outputs/',parm$output,'/',cl))
  save(CM.reg,file=paste0('outputs/',parm$output,'/',cl,'/Connectivity.Rdata'))
  write.csv(CM.reg,file=paste0('outputs/',parm$output,'/',cl,'/Connectivity.csv'))
  
})