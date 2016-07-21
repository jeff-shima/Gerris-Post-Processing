# Gerris-Post-Processing
Post processing for Gerris runs

## Clone from github
### In RStudio
Go to the project menu (upper right corner). Select new project -> from version control -> from github -> insert project https URL from the github page: ```https://github.com/jeff-shima/Gerris-Post-Processing.git```

### Outside of Rstudio
Go to the directory to which you want to clone the project, then ```git clone https://github.com/jeff-shima/Gerris-Post-Processing.git```

## Set up in RStudio
To open the project, go to the project menu (upper right corner) and select the project.

NOTE: the following build setup should (hopefully) not be necessary since the setup is written in the .Rproj config file.
In the ```Tools``` menu, go to ```Project Options```, then ```Build tools```. Set build to ```Custom```, then browse to ```run.sh```.

## Setting up post processing

Download the model runs from [Gorbachev](https://gorbachev.io/#/report/Gerris-in-the-cloud). Copy the archive and Cook.yaml to the outputs/ folder of the current project. No need to unzip etc, this will be done automatically within the build.

Use the process.yaml file to set the parameters of the competency and swimming functions, and to define the outputs to be processed. The .yaml parameters are documented in process.html.

## Running the post-processing

Go to the build tab, and click ```build all```, or use the hotkey ```Ctrl + Shift + B```.

## Outputs

The function will output at two scales: 

1. At the scale of individual releases: 
    * Connectivity matrices are saved as .Rdata, .csv and a .png plot.
2. At the regional/cloudlabel scale: 
    * The competency and settlement functions are plotted, and 
    * summed (over releases) connectivity matrices are saved as .Rdata, .csv and a .png plot.
3. The config file ```Cook.yaml``` is saved to include the parameter file that lead to the set of outputs.

All outputs are saved under ```outputs/<<run date>>.```.
