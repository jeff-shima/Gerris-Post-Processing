# Gerris-Post-Processing
Post processing for Gerris runs

## Set up in RStudio
NOTE: this should npot be necessary since the setup is written in the .Rproj config file.

In the ```Tools``` menu, go to ```Project Options```, then ```Build tools```. Set build to ```Custom```, then browse to ```run.sh```.

## Setting up post processing

Use the .yaml file to set the parameters of the competency and swimming functions, and to define the outputs to be processed.

## Running the post-processing

Go to the build tab, and click ```build all```.

## Outputs

The function will output at two scales: 

1. At the scale of individual releases: 
    * Connectivity matrices are saved as .Rdata, .csv and a .png plot.
2. At the regional/cloudlabel scale: 
    * The competency and settlement functions are plotted, and 
    * summed (over releases) connectivity matrices are saved as .Rdata, .csv and a .png plot.
3. The config file ```Cook.yaml``` is saved to include the parameter file that lead to the set of outputs.

All outputs are saved under ```outputs/<<run date>>.```.
