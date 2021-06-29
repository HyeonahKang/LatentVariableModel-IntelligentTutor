fitstat <- function(modout, modfit){
  
  nstate <- modout@nstates
  ntime <- unique(modout@ntimes)
  nexaminee <- length(modout@ntimes)
  pr_state <- posterior(modfit)
  pr_init <- apply(modfit@init, 2, unique)
  pr_tr <- t(modfit@trDens[1,,1:nstate])
  
  st  <- matrix(NA, nexaminee * ntime, 3, dimnames=list(NULL, c("s", "prs", "prt")))
  # 'pro': emission probability (observation model)
  # 'prs': state posterior probability (given y, s_0)
  # 'prt': transition probability
  y1 <- matrix(NA, nexaminee * ntime, 4, dimnames=list(NULL, c("y", "mu", "sd", "pro")))
  y1[,'y'] <- modout@response[[1]][[1]]@y
  # first index: state; second index: indicator
  if (modout@nresp>=2) {
    y2 <- matrix(NA, nexaminee * ntime, 3, dimnames=list(NULL, c("y", "lam", "pro")))
    y2[,'y'] <- modout@response[[1]][[2]]@y
  } 
  if (modout@nresp>=3){
    y3 <- matrix(NA, nexaminee * ntime, 3, dimnames=list(NULL, c("y", "lam", "pro")))
    y3[,'y'] <- modout@response[[1]][[3]]@y
  }
  
  for (i in 1:(ntime*nexaminee) ){# i<-1
    
    st[i,'s'] <- s <- pr_state[i,'state'] # estimated state
    st[i,'prs'] <- pr_state[i,pr_state[i,1]+1]
    if (i==1){
      st[i, 'prt'] <- pr_init[s]
    } else {
      st[i, 'prt'] <- pr_tr[st[i-1,'s'], s]
    }
    
    y1[i,'mu'] <- mu <- modfit@response[[s]][[1]]@parameters$coefficients 
    y1[i,'sd'] <- std <- modfit@response[[s]][[1]]@parameters$sd
    y1[i, 'pro'] <- dnorm(y1[i], mean=mu, sd=std)
    
    if (modout@nresp>=2){
      y2[i,'lam'] <- lam <- exp(modfit@response[[s]][[2]]@parameters$coefficients)
      ## GLM based poisson) Exponentiate coeff
      y2[i,'pro'] <- dpois(y2[i], lam)
    } 
    if (modout@nresp>=3){
      y3[i,'lam'] <- lam <- exp(modfit@response[[s]][[3]]@parameters$coefficients)
      y3[i,'pro'] <- dpois(y3[i], lam)
    }  
  }
  
  if (modout@nresp==1){
    summfit <- list(y1=y1, st=st)
    jointlike <- sum(log(summfit$y1[,'pro'] * summfit$st[,"prt"]))
    nfree <- (nstate - 1) + (nstate - 1) * nstate + nstate * 2
    # (# init prob pars: multinomial) + (# transition prob) + (# emission prob pars)
  } else if (modout@nresp==2) {
    summfit <- list(y1=y1, y2=y2, st=st)
    jointlike <- sum(log(summfit$y1[,'pro'] * summfit$y2[,'pro'] * summfit$st[,"prt"]))
    nfree <- (nstate - 1) + (nstate - 1) * nstate + nstate * 3    
  } else if (modout@nresp==3){
    summfit <- list(y1=y1, y2=y2, y3=y3, st=st)
    jointlike <- sum(log(summfit$y1[,'pro'] * summfit$y2[,'pro'] * summfit$y3[,'pro'] * summfit$st[,"prt"]))
    nfree <- (nstate - 1) + (nstate - 1) * nstate + nstate * 4
  } 
  
  aic  <- - 2 * jointlike + nfree 
  caic <- - 2 * jointlike + nfree * (log(ntime*nexaminee) + 1) 
  bic  <- - 2 * jointlike + nfree * log(ntime*nexaminee) 
  abic <- - 2 * jointlike + nfree * log((ntime*nexaminee + 2) / (24))   
  
  fitstat <- c(jointlike, aic, caic, bic, abic, nfree)
  names(fitstat) <- c("llike", "aic", "caic", "bic", "abic", "npar")
  return(fitstat)
}

