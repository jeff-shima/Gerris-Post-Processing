#' this is a closure - it will return a function based on the selected type of settlement function.
#'
#' @param
#' @ To write a new function, add a new case to the switch statement and choose the type in the parameter (yaml) file.

compfunc <- function(type = 'C&B'){

    switch(type,
           `C&B` = function(tmax, int,pars){
               attach(pars)
               dt <- c(rep(0,devtime),seq(int,(tmax-devtime),int))/3600
               (aqn*(exp(-aqn*dt)-exp(-loss*dt))/(loss-aqn))*exp(-(mort*dt))^0.5;
           })
}

swimfunc <- function(type = 'negExp'){

    switch(type,
           negExp = function(dists,pars){
               attach(pars)
               exp(-dists/dmax)
           })
}

#' plot settlement
#' @param swimtype type of swimming function
#' @param comptype type of competency function
plot_settlement <- function(swimtype, comptype){
  
  yaml.config <- "../control/Cook.yaml"
  
}

