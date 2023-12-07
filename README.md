History Matching ORCHIDEE
=========================
An application of History Matching in ORCHIDEE Land Surface Model

Installation
============

This repository uses the R front end [ExeterUQ_MOGP](https://github.com/BayesExeter/ExeterUQ_MOGP) for [mogp_emulator](https://github.com/alan-turing-institute/mogp_emulator) (released in Python).  You need to install both repositories, (be sure to install moqp_emulator V0.5).

We recommend that you install and use the conda environment provided in this repository. 

    $ conda install -c conda-forge --name HM --file requirements.txt 
    $ conda activate HM

Please provide the path of mopg_emulator and ExeterUQ_MOGP on lines 2 and 3 of the info.csv file in the data directory.  
    
Usage
=====

This repository provides an R script that executes a wave of 'History Matching'. This script can be used for any dataset, as long as the format respects the same convention as the example provided in the Data directory. The data provided here are output metrics calculated from ORCHIDEE land surface model simulations using 6 different parameters. 

To launch a Wave of Histrory Matching please run the flowing line: 

    $ Rscript R/HistoryMatching.R /$Ablosulte_path$/Data/$Directory_name$/ 

The info.csv file provides options for the R script: 
+ l4 Wave number 
+ l5 Sample size to be generated with emulatore 
+ l6 cut-off
+ l7 tau
+ l8 option to use previous sample
+ l9 option to create a new design for the next wave (to be used when NROY is too small) 
+ l10 option to keep good point in order to have a more real simulation point for the next wave
+ l11 keep good point only on the border (must activate l10 to use this option) 

Reference publications
======================

Contributors
============
Simon Beylat, Nina Raoult 
This scipte is an adaptation of the scripte used in [HighTune](https://svn.lmd.jussieu.fr/HighTune/) available on svn
