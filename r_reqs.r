old <- getOption("defaultPackages"); 
r <- getOption("repos")
r["CRAN"] <- "http://cran.stat.auckland.ac.nz"
options(defaultPackages = c(old, "MASS","methods"), repos = r)

packages <- c(
    'data.table','knitr','yaml','dplyr','ggplot2','R.utils','viridis'
)

for (p in packages) {
    if (!require(p, character.only=TRUE)) {
        install.packages(p)
    }
}