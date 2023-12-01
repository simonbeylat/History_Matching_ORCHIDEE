#! /usr/bin/Rscript
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  path_out <- args[1]
}
library(reticulate)
Sys.setenv(RETICULATE_PYTHON = "/home/users/sbeylat/.conda/envs/HM/bin/python")
use_condaenv(condaenv='HM')


Info <- read.csv(paste(path_out,'info.csv',sep=''))
path_mogp <- as.character(Info[1,1])
path_ExeterUQ <-as.character(Info[2,1])
WAVE=as.numeric(Info[3,1])
sample_size <-as.numeric(Info[4,1])
cutoff_vec <-as.numeric(Info[5,1])
valmax <-as.numeric(Info[6,1]) #how many outputs can be above the implausibility cut off?
USE_PAST <-as.logical(as.numeric(Info[7,1]))
NEWDESIGN<-as.logical(as.numeric(Info[8,1]))
KEEPIT<-as.logical(as.numeric(Info[9,1]))
KEEPBORN <-as.logical(as.numeric(Info[10,1]))

print(paste("Number of Wave :",WAVE))
print(paste("Size of sample to emulate :",sample_size))
print(paste("cutoff :",cutoff_vec))
print(paste("valmax :",valmax))
print("config :")
print(paste("using paste sample :",USE_PAST))
print(paste("Create new sample :",NEWDESIGN))
print(paste("Keep good point :",KEEPIT))
if(KEEPIT){print(paste("only border :",KEEPBORN))}
print("_______________________________________________________________")
print("Start History Matching")

path_dir=paste(path_out,'WAVE',WAVE,'/',sep='')
print(path_ExeterUQ)
print(path_mogp)

mogp_dir <- path_mogp

print('load package')
setwd(path_ExeterUQ)
source("BuildEmulator/BuildEmulator.R")
source("HistoryMatching/HistoryMatching.R")
source("HistoryMatching/impLayoutplot.R")

setwd(path_dir)

tData <- read.csv(paste(path_dir,'Data4Emulatore.csv',sep=''))

if(KEEPIT){
if(file.exists(paste(path_out,'WAVE',WAVE-1,'/Keepit.csv',sep=''))){
print("Get old point")
Old<-read.csv(paste(path_out,'WAVE',WAVE-1,'/Keepit.csv',sep=''))
tData<-rbind(tData,Old)
}}


print(nrow(tData))
nparam <- which(names(tData)=="Noise")-1
nEm=length(names(tData)) - which(names(tData)=="Noise")

print("Train Emulatore")
TestEm <- BuildNewEmulators(tData, HowManyEmulators = nEm, meanFun = "fitted",additionalVariables = names(tData)[1:nparam]) 

### change to load data
print("load Data") 
obs <- read.csv(paste(path_dir,'Obs.csv',sep=''))
tObs <- as.numeric(as.vector(obs[1,]))
tObsErr <- as.numeric(as.vector(obs[2,]))
tDisc <- rep(0,nEm)


VarNames <- names(TestEm$fitting.elements$Design)
reduction = c()

if(WAVE==1){

Xp <- as.data.frame(2*randomLHS(sample_size, nparam)-1)
names(Xp) <- names(TestEm$fitting.elements$Design)
Timps <- ImplausibilityMOGP(NewData=Xp, Emulator=TestEm, Discrepancy=tDisc, Obs=tObs, ObsErr=tObsErr**2)

}else{

if(USE_PAST){
  
print('USE PAST SAMPLE')
path_past=paste(path_out,'WAVE',WAVE-1,'/',sep='')
NROY_Past=unlist(read.csv(paste(path_past,'NROY.csv',sep='')))
Data_past=read.csv(paste(path_past,'DataWave.csv',sep=''))

Xp=Data_past[,1:nparam]
Timps_past=Data_past[,(nparam+1):(nparam+nEm)]

Timps <- matrix(rep(t(Timps_past),1), ncol=ncol(Timps_past), byrow=TRUE)
Timps[NROY_Past,] <- ImplausibilityMOGP(NewData=Xp[NROY_Past,], Emulator=TestEm, Discrepancy=tDisc, Obs=tObs, ObsErr=tObsErr**2)
}else{
  print('GENERATE NEW SAMPLE')
  Xp <- as.data.frame(2*randomLHS(sample_size, nparam)-1)
  names(Xp) <- names(TestEm$fitting.elements$Design)
  if(file.exists(paste(path_out,'cutoff.csv',sep=''))){cutoff_past <- unlist(read.csv(paste(path_out,'cutoff.csv',sep='')))}
  else{cutoff_past=rep(3,WAVE)}
  for(iwave in 1:(WAVE-1)){
    print(paste('load Wave:',iwave))
    path_past=paste(path_out,'WAVE',WAVE-iwave,'/',sep='')
    EM <- load_ExUQmogp(paste(path_past,"Emulator",sep=''))
    if (iwave==1){
      Timps <- ImplausibilityMOGP(NewData=Xp, Emulator=EM, Discrepancy=tDisc, Obs=tObs, ObsErr=tObsErr**2)
    }else{
      Timps[NROY_wave,] <- ImplausibilityMOGP(NewData=Xp[NROY_wave,], Emulator=EM, Discrepancy=tDisc, Obs=tObs, ObsErr=tObsErr**2)
    }
    NROY_wave <- which(rowSums(Timps <= cutoff_past[iwave]) >= EM$mogp$n_emulators -valmax)
    ratio<-length(NROY_wave)/dim(Xp)[1]
    reduction=append(reduction,ratio)
    print(ratio)
    }
  Timps[NROY_wave,] <- ImplausibilityMOGP(NewData=Xp[NROY_wave,], Emulator=TestEm, Discrepancy=tDisc, Obs=tObs, ObsErr=tObsErr**2)
}
}


print('get prediction')

#param.defaults.norm=rep(0,nparam) #the default parameters of the model (on [-1,1])
#param.defaults.norm=c(-0.2,-0.2972973,0.2,0.53846154,-0.57142857,0.25454545) 

ImpData_wave = cbind(Xp, Timps)

ImpListM1 = CreateImpList(whichVars = 1:nparam, VarNames=VarNames, ImpData=ImpData_wave,
                            nEms=TestEm$mogp$n_emulators, whichMax=valmax+1,Cutoff=cutoff_vec)

print('get NROY')                          
NROY <- which(rowSums(Timps <= cutoff_vec[1]) >= TestEm$mogp$n_emulators -valmax)
ratio<-length(NROY)/dim(Xp)[1]
print(ratio)
reduction=append(reduction,ratio)

print('create images')
pdf(file="NROY.pdf")
imp.layoutm11(ImpListM1, VarNames, VariableDensity=FALSE, newPDF=FALSE, 
                the.title=paste("InputSpace_wave",WAVEN,".pdf",sep=""), 
                newPNG=FALSE, newJPEG=FALSE, newEPS=FALSE)
                #Points=matrix(param.defaults.norm,ncol=nparam))
mtext(paste("Remaining space:",length(NROY)/dim(Xp)[1],sep=""), side=1)
dev.off()


designpoints <- data.frame()

if(NEWDESIGN){
while (nrow(designpoints) <= 10*nparam) {
#        tmp <- as.data.frame(2*maximinLHS(ceil((10*nparam)/ratio), nparam)-1)
        tmp <- as.data.frame(2*randomLHS(ceil((10*nparam)/ratio), nparam)-1)
        names(tmp) <- names(TestEm$fitting.elements$Design)
        imps_tmp <- ImplausibilityMOGP(NewData=tmp, Emulator=TestEm, Discrepancy=tDisc, Obs=tObs, ObsErr=tObsErr**2)
        NROYtmp <- which(rowSums(imps_tmp <= cutoff_vec[1]) >= TestEm$mogp$n_emulators -valmax)
        selectionP <- tmp[NROYtmp,]
        row.names(selectionP) <- NULL ## to avoid double index
        designpoints <- rbind(designpoints,selectionP)
        print(nrow(designpoints))
        flush.console()
        } 
}else{
print("Sample in NROY")
designpoints=Xp[NROY,]
}

if(nrow(designpoints)>10*nparam){designpoints <- designpoints[sample(nrow(designpoints),10*nparam),]}


if(KEEPIT){
  tmp <-tData[,1:nparam]
  imps_tmp <- ImplausibilityMOGP(NewData=tmp, Emulator=TestEm, Discrepancy=tDisc, Obs=tObs, ObsErr=tObsErr**2)
  if(KEEPBORN){
    NROYtmp <- which(rowSums(imps_tmp <= cutoff_vec[1] & imps_tmp >= cutoff_vec[1]-0.5) > 0)
  }else{
    NROYtmp <- which(rowSums(imps_tmp <= cutoff_vec[1]) >= TestEm$mogp$n_emulators -valmax)
  }
  selectionP <- tData[NROYtmp,]
  write.csv(selectionP,"Keepit.csv", row.names = FALSE)
}

write.csv(ratio,"ratio.csv", row.names = FALSE)
write.csv(designpoints,"Data4NestWave.csv", row.names = FALSE)
if(USE_PAST){
write.csv(ImpData_wave,"DataWave.csv", row.names = FALSE)
write.csv(NROY,"NROY.csv", row.names = FALSE) 
}
write.csv(ImpListM1,"Imp.csv", row.names = FALSE) 
save_ExUQmogp(TestEm, filename = "Emulator")



pdf(file="Plots_LOO.pdf")
for(i in 1:nEm){
  tLOOs <- LOO.plot(Emulators = TestEm, which.emulator = i, ParamNames = VarNames, Obs = tObs[i], ObsErr = tObsErr[i],ObsRange=TRUE)
}
dev.off()

png('NROY_Reduction.png')
plot(reduction,type='b',col='red',pch=19,xlab = "WAVE", ylab = "NROY",ylim=c(0,1))
dev.off()
