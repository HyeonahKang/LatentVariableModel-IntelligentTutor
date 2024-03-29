

pdf('traceplots.pdf')
traceplot(mod,par='lp__')
traceplot(mod,par='beta')
dev.off()

## measurement parameters
meas0 <- rstan::extract(mod,par=c('meanTime','sigTime','effErr','effHint','cHint','cErr'),permute=FALSE)

measd0 <- tibble(
  draw=as.vector(meas0),
  iter=rep(1:dim(meas0)[1],prod(dim(meas0)[2:3])),
  chain=rep(rep(dimnames(meas0)$chains,each=dim(meas0)[1]),dim(meas0)[3]),
  parameter=rep(dimnames(meas0)$parameters,each=prod(dim(meas0)[1:2]))
)

ggplot(measd0,aes(iter,draw,color=chain,group=chain))+
  geom_line()+
  facet_wrap(~parameter,scales="free_y")
ggsave('measd0.pdf')


## some reverse coding necessary....
means <- apply(meas0,c(2,3),mean)%>%
  as.data.frame()%>%select(-starts_with('c'))

## for Appendix B
print(xtable(means),file='tableA2.tex')

## want sigTime \approx .76
## chains where it's .84 should get reversed
revCode <- which(trunc(means[,'sigTime[1]']*10)==8)

meas <- meas0
meas[,revCode,] <- meas[,revCode,c(2,1,4,3,6,5,8,7,9:12)]

apply(meas,c(2,3),mean)

## rhats

rhat <- function(mat){
    B <- var(colMeans(mat))
    W <- mean(apply(mat,2,var))
    sqrt(((nrow(mat)-1)/nrow(mat)*W+B)/W)
}

print(xtable(
    rbind(
        Original=apply(meas0[,,1:8],3,rhat),
        Relabeled=apply(meas[,,1:8],3,rhat)
        )),file='tableA3.tex')


## new traceplot

measd <- tibble(
    draw=as.vector(meas),
    iter=rep(1:dim(meas)[1],prod(dim(meas)[2:3])),
    chain=rep(rep(dimnames(meas)$chains,each=dim(meas)[1]),dim(meas)[3]),
    parameter=rep(dimnames(meas)$parameters,each=prod(dim(meas)[1:2]))
)

ggplot(measd,aes(iter,draw,color=chain,group=chain))+
    geom_line()+
    facet_wrap(~parameter,scales="free_y")
ggsave('newTraceplot.pdf')


disp <- function(x) paste0(
                        sprintf("%.3f", round(mean(x),3)),
                        ' (',sprintf("%.3f", round(sd(x),3)),')'
                    )

tab3 <- measd%>%
  filter(!startsWith(parameter,'c'))%>%
    mutate(par=substr(parameter,1,nchar(parameter)-3),
           par=factor(par,levels=unique(par)),
           class=substr(parameter,nchar(parameter)-1,nchar(parameter)-1)
           )%>%
    group_by(par)%>%
    summarize(
        `State 1`=disp(draw[class=='1']),
        `State 2`=disp(draw[class=='2']),
        `Difference`=disp(draw[class=='1']-draw[class=='2'])
    )



cTab <- measd%>%
  filter(startsWith(parameter,'c'))%>%
  group_by(parameter)%>%
  summarize(`State 1`=disp(draw))
print(xtable(cTab),file='tab3cutoffs.pdf')

### probabilities
nu <- rstan::extract(mod,par='nu',permute=FALSE)
nu[,revCode,] <- 1-nu[,revCode,]
quantile(apply(nu,3,rhat))

meanNu <- apply(nu,c(1,2),function(x) mean(x[sdat$stud]))
rhat(meanNu)

tibble(draw=as.vector(meanNu),
       iter=rep(1:nrow(meanNu),ncol(meanNu)),
       chain=rep(colnames(meanNu),each=nrow(meanNu)))%>%
    ggplot(aes(iter,draw,color=chain,group=chain))+geom_line()+
    ggtitle(expression(paste('E',nu)))
ggsave('traceplotMeanNu.pdf')

tab3 <- bind_rows(
    tab3,
    tibble(par='Probability',`State 1`=disp(meanNu),`State 2`=disp(1-meanNu))
)

tab3$par[1:4] <- c('Time (mean)','Time (SD)','Error','Hint')
tab3$Notation <- c('$\\mu_{1m}$','$\\sigma_{m}$','$\\mu_{2m}$','$\\mu_{3m}$',' ')

tab3 <- tab3[,c(1,5,2:4)]

print(xtable(tab3),include.rownames=FALSE,
      sanitize.text.function = function(x) x,
      floating=FALSE,file='tab3.tex')

## coef table
beta <- rstan::extract(mod,par='beta',permute=FALSE)

beta[,revCode,] <- -beta[,revCode,]
beta <- -beta ## parameterized model opposite like

apply(beta,3,rhat)

dimnames(beta)$parameters <- colnames(sdat$X)

tab3 <- tibble(
    Covariate=dimnames(beta)$parameters,
    Est=sprintf("%.3f", round(apply(beta,3,mean),3)),
    SE=sprintf("%.3f", round(apply(beta,3,sd),3)),
    pval=sprintf("%.3f", round(apply(beta,3,function(x) 2*min(mean(x<0),mean(x>0))),3))
     )
print(xtable(tab3),file='tab4.tex')


varComp <- summary(mod,par=c('sigProb','OmegaProb','sigStud'),probs=c(0.025,0.975))$summary%>%round(3)


## variance of fitted values
yh <- sd(sdat$X%*%apply(beta,3,mean))

varComp <- rbind(varComp,VfittedVal=c(yh,rep(NA,ncol(varComp)-1)))

print(xtable(varComp),file='varComp.tex')
