
load("CTA_OneUnit_SDay.RData")
library(depmixS4)
source("scompute.R")

### Fit HMM ------------------
nstd <- length(data_prob_cta101_sday)
nafitmat <- matrix(NA, 10, 7, 
                   dimnames=list(seq(1,10), c("ll", "aic", "caic", "bic", "abic", "npar", "nitr")))
hmm_indv <- vector(mod="list", length=nstd)

# start_time <- Sys.time()
for (i in 1:nstd){ # i <- 1
  
  print(paste0("---- i=", i, " -----"))
  
  datai <- data_prob_cta101_sday[[i]]
  fitmat <- nafitmat
  
  ### One-state HMM
  nitr <- 0
  while (nitr <= 100){
    nitr <- nitr + 1;
    ## Note. One-state model can't have covariate
    modout <- depmix(
      list(ltime ~ 1, nhints1 ~ 1, nerrs1 ~ 1),
      family=list(gaussian(), poisson(), poisson()),
      nstates=1,
      instart=1,
      data=datai)
    
    modfit <- tryCatch({modfit <- fit(modout)}, error=function(e){modfit <- NULL})
    if (exists("modfit") && !is.null(modfit)){break;}
    rm(modout, modfit)
  }
  fitmat[1,'nitr'] <- nitr
  
  if (nitr <= 100){
    fitmat[1,1:6] <- fitstat(modout, modfit)
    rm(modout, modfit, nitr)
  }
  
  for (ns in 2:10){# ns<-2
    
    nitr <- 0
    while (nitr <= 100){
      
      nitr <- nitr + 1;
      modout <- depmix(
        list(ltime ~ 1, nhints1 ~ 1, nerrs1 ~ 1),
        family=list(gaussian(), poisson(), poisson()),
        nstates=ns,
        transition=~pretest +~gainscore +~race +~sex +~frl +~esl,
        data=datai)
      
      modfit <- tryCatch({modfit <- fit(modout)}, error=function(e){modfit <- NULL})
      
      if (exists("modfit") && !is.null(modfit)){break;}
      rm(modout, modfit)
    }
    
    fitmat[ns,'nitr'] <- nitr
    if (nitr <= 100){
      fitmat[ns,1:6] <- fitstat(modout, modfit)
      rm(modout, modfit, nitr)
    }
    
  } # end of ns
  
  
  ### Estimated nstates by each fit criterion
  nshat <- rep(NA, 5); names(nshat) <- c("ll", "aic", "caic", "bic", "abic")
  for (k in 1:5){
    if (k==1){# loglike
      tmp <- sort.int(fitmat[,k], decreasing=T, index.return=T); nshat[k] <- tmp$ix[1]
    } else {
      tmp <- sort.int(fitmat[,k], index.return=T); nshat[k] <- tmp$ix[1]
    }
  }
  
  hmm_indv[[i]]$fitmat <- fitmat
  hmm_indv[[i]]$nshat  <- nshat
  
  rm(fitmat, nshat, datai)
  
}
# end_time <- Sys.time()
# proc_time <- end_time - start_time
hmm_indv_cta101_sday <- hmm_indv

save.image("B1_CTA_HMM_ProbFit_cta101_SDay.RData")
