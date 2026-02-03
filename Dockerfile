FROM condaforge/miniforge3:24.7.1-0
WORKDIR /app

COPY environment.yml /app/environment.yml
RUN mamba env create -f /app/environment.yml \
 && mamba clean -a -y

COPY . /app
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "HM", "Rscript", "R/HistoryMatching.R"]

CMD ["/data/Raoult2024/RMSD/"]
