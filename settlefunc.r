#' this is a closure - it will return a function based on the selected type of competency function.
#'
#' @param type the type of function to use for compentency.
#' C\&B: Connoly & Baird 2004 (Ecology)
#'       devtime: lag time before aquisition of compentency
#'       aqn: competency aquisition rate (per hour)
#'       loss: competency loss rate (per hour)
#'       mort: mortality rate (per hour)
#'       
#' Uniform settlement: settlement probability =1 within competancy window
#'      cmin: lag time before aquisition of compentency
#'      cmax: time at loss of compentency
#'       
#' @details  To write a new function, add a new case to the switch statement and choose the type in the parameter (yaml) file.

compfunc <- function(type = 'C&B'){

    switch(type,
           `C&B` = function(pars,...){
             attachLocally(pars)
             attachLocally(list(...))
             dt <- c(rep(0,devtime),seq(tmin,(tmax-devtime),int))/3600
             (aqn*(exp(-aqn*dt)-exp(-loss*dt))/(loss-aqn))*exp(-(mort*dt))^0.5;
           },
           uniform = function(pars){
             c(rep(0,cmin),rep(1,cmax-cmin),rep(0,(tmax-cmax)))
           })
}


#' this is a closure - it will return a function based on the selected type of swiiming function.
#'
#' @param type the type of function to use for compentency
#' @details  To write a new function, add a new case to the switch statement and choose the type in the parameter (yaml) file.
swimfunc <- function(type = 'negExp'){

    switch(type,
           negExp = function(dists,pars){
                attachLocally(pars)
               exp(-dists/dmax)
           })
}

#' plot settlement
#' @param swimtype type of swimming function
#' @param comptype type of competency function
plot_settlement <- function(swimtype, comptype){
  
  yaml.config <- "../control/Cook.yaml"
  
}

