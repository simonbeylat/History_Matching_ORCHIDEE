#!/usr/bin/env bash
set -e

git clone https://github.com/BayesExeter/ExeterUQ_MOGP.git
git clone https://github.com/alan-turing-institute/mogp-emulator.git
cd mogp-emulator
git checkout tags/v0.5.0

sed -i 's/^from \.version/#from \.version/' mogp_emulator/__init__.py

cd ../
docker build -t hm-orchidee .
docker run --rm -it -v "$PWD/Data:/data" hm-orchidee /data/Raoult2024/RMSD/
