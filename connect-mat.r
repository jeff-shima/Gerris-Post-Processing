require(dplyr)
require(data.table)
require(yaml)
source('settlefunc.r')

repmat = function(X,m,n){
  ##R equivalent of repmat (matlab)
  mx = dim(X)[1]
  nx = dim(X)[2]
  matrix(t(matrix(X,mx,nx*n)),mx*m,nx*n,byrow=T)
}

geodetic.distance <- function(point1, point2) 
{ 
  R <- 6371 
  p1rad <- point1 * pi/180 
  p2rad <- point2 * pi/180 
  d <- (sin(p1rad[,2]) %o% sin(p2rad[,2]))+(cos(p1rad[,2]) %o% cos(p2rad[,2])) * cos(abs(outer(p2rad[,1],p1rad[,1],'-')))	
  d <- acos(d) 
  d[is.nan(d)] <- 0
  R*d 
} 

yaml.config <- "../control/Cook.yaml"
parm <- yaml.load_file(yaml.config)

files <- dir('../run/output/')
cloudy <- do.call(rbind,strsplit(files,'-'))
cloudy[,2] <- as.numeric(do.call(rbind,strsplit(cloudy[,2],'\\.'))[,1])
cloudy <- data.frame(cloudy)
colnames(cloudy) <- c('cloud','t')

cloudnames <- unique(cloudy$cloud)
regionames <- unlist(lapply(parm$Regions,function(x) x$RegionName))
comp_pars <- parm$compfunc
swim_pars <- parm$swimfunc

cfunc <- compfunc(comp_pars$type)
sfunc <- swimfunc(swim_pars$type)

lapply(cloudnames, function(cl) {

    this.cl <- cloudy %>% filter(cloud == cl) %>% arrange(t)
    files <- paste0('../run/output/',apply(this.cl,1,paste, collapse='-'),'.dat')
    
    this_comp_par <- parm$Regions[[which(!is.na(sapply(regionames,grep,cl)>0))]]
    cprob <- cfunc(tmax=this_comp_par$start+this_comp_par$duration,
          int = this_comp_par$outputInterval,
          pars = comp_pars
          )
    
    clouds <- lapply(files, fread, skip=0, select=1:4, 
                     colClasses=c('numeric', 'numeric', 'numeric', 'numeric'), 
                     nrows=R.utils::countLines(files[1])-3)

    origin <- as.data.frame(clouds[[1]])
    names(origin) <- c('id','long','lat','depth')
    n <- nrow(origin)
    frac <- rep(1,n)
    
    clouds <- clouds[-1]

    lapply(clouds, function(tcl) {
      tcl <- as.data.frame(tcl)
      names(tcl) <- c('id','long','lat','depth')
      #this does that
      dists <- geodetic.distance(tcl[,c('long','lat')],
                                 origin[,c('long','lat')])
      
      sprob <- sfunc(dists = dists,
            pars = swim_pars)
      tprob = repmat(frac) * rowSums(sprob) * cprob/n
    })      
}
)
