History Matching ORCHIDEE
=========================
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10592299.svg)](https://doi.org/10.5281/zenodo.10592299)


An application of History Matching in ORCHIDEE Land Surface Model


Installation
============

This repository uses the R front end [ExeterUQ_MOGP](https://github.com/BayesExeter/ExeterUQ_MOGP) for [mogp_emulator](https://github.com/alan-turing-institute/mogp_emulator) (released in Python).  You must install both repositories (be sure to install moqp_emulator V0.5).

We recommend that you install and use the conda environment provided in this repository. 

    $ conda install -c conda-forge --name HM --file requirements.txt 
    $ conda activate HM

Please provide the path of mopg_emulator and ExeterUQ_MOGP on lines 2 and 3 of the info.csv file in the data directory.  
    
Usage
=====

This repository provides an R script that executes a wave of 'History Matching'. This script can be used for any dataset as long as the format respects the same convention as the example provided in the Data directory. The data provided here are output metrics calculated from ORCHIDEE land surface model simulations using six different parameters. 

To launch a Wave of History Matching please run the following line: 

    $ Rscript R/HistoryMatching.R /$Ablosulte_path$/Data/$Directory_name$/ 

The info.csv file provides options for the R script: 
+ l4 Wave number 
+ l5 Sample size to be generated with emulator 
+ l6 cut-off
+ l7 tau
+ l8 option to use a previous sample
+ l9 option to create a new design for the next wave (to be used when NROY is too small) 
+ l10 option to keep good points in order to have a more real simulation point for the next wave
+ l11 keeps good points only on the border (must activate l10 to use this option) 

Reference publications
======================
'Dry snow initialization and densification over the Greenland and Antarctic ice sheets in the ORCHIDEE land surface model' Conesa et al 2025 DOI : 
'Exploring the Potential of History Matching for Land Surface Model Calibration' Raoult et al. 2023 DOI : http://dx.doi.org/10.5194/egusphere-2023-2996 
  
Contributors
============
Simon Beylat, Nina Raoult 
This script is an adaptation of the script used in [HighTune](https://svn.lmd.jussieu.fr/HighTune/) available on svn.

