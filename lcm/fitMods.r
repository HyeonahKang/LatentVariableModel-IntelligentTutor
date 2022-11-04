### point estimates via optimization

stanmod <- stan_model('lca2class2.stan')

sdat$sigStud <- 1
fit1 <- optimizing(stanmod,data=sdat,hessian=TRUE)#,draws=200,importance_resampling=TRUE)

oneClassMod <- stan_model('lca1class.stan')
fit1class <- optimizing(oneClassMod,data=sdat,hessian=TRUE,draws=2000,importance_resampling=TRUE)
save(fit1class,sdat,oneClassMod,file='fit1class.RData')

#### no student effects or covariates
mod0 <- stan_model('lca2class0.stan')
fit00 <- optimizing(mod0,data=sdat,hessian=TRUE,draws=2000,importance_resampling=TRUE)

#### yes student effects no covariates
mod1 <- stan_model('lca2class1.stan')
sdat$sigStud <- 1
fit01 <- optimizing(mod1,data=sdat,hessian=TRUE,draws=2000,importance_resampling=TRUE)

save(fit1,fit00,fit01,mod0,mod1,sdat,file='prelimMods.RData')

#### main model via MCMC (takes a looooong time)

options(mc.cores=8)
rstan_options(auto_write=TRUE)

mod <- stan('lca2class.stan',data=sdat,iter=2000,chains=8)
save(mod,file='lcaStan4-7.RData')
