# ###info.rank#########################################################################


#' Info-rank plot
#' 
#' Produces a plot similar to a Tornado-plot, but based on the analysis of the
#' EVPPI. For each parameter and value of the willingness-to-pay threshold, a
#' barchart is plotted to describe the ratio of EVPPI (specific to that
#' parameter) to EVPI. This represents the relative 'importance' of each
#' parameter in terms of the expected value of information.
#' 
#' 
#' @param parameter A vector of parameters for which the individual EVPPI
#' should be calculated. This can be given as a string (or vector of strings)
#' of names or a numeric vector, corresponding to the column numbers of
#' important parameters.
#' @param input A matrix containing the simulations for all the parameters
#' monitored by the call to JAGS or BUGS. The matrix should have column names
#' matching the names of the parameters and the values in the vector parameter
#' should match at least one of those values.
#' @param he A \code{bcea} object (the result of the call to the function
#' \code{\link{bcea}}).
#' @param wtp A value of the wtp for which the analysis should be performed. If
#' not specified then the break-even point for the current model will be used.
#' @param ...  Additional options. These include graphical parameters that the
#' user can specify. xlim = limits of the x-axis; ca = font size for the axis
#' label (default = 0.7 of full size); cn = font size for the parameter names
#' vector (default = 0.7 of full size); mai = margins of the graph (default =
#' c(1.36,1.5,1,1)); rel = logical argument that specifies whether the ratio of
#' EVPPI to EVPI (\code{rel=TRUE}, default) or the absolute value of the EVPPI
#' should be used for the analysis.
#' @return \item{res}{ A data.frame containing the ranking of the parameters
#' with the value of the selected summary, for the chosen wtp. } The function
#' produces a 'Info-rank' plot. This is an extension of standard 'Tornado
#' plots' and presents a ranking of the model parameters in terms of their
#' impact on the expected value of information. For each parameter, the
#' specific individual EVPPI is computed and used to measure the impact of
#' uncertainty in that parameter over the decision-making process, in terms of
#' how large the expected value of gaining more information is.
#' @author Anna Heath, Gianluca Baio
#' @seealso \code{\link{bcea}}, \code{\link{evppi}}
#' @references Baio, G., Dawid, A. P. (2011). Probabilistic Sensitivity
#' Analysis in Health Economics.  Statistical Methods in Medical Research
#' doi:10.1177/0962280211419832.
#' 
#' Baio G. (2012). Bayesian Methods in Health Economics. CRC/Chapman Hall,
#' London
#' @keywords Health economic evaluation Probabilistic sensitivity analysis
#' @export info.rank
info.rank <- function(parameter,input,he,wtp=he$k[min(which(he$k>=he$ICER))],...) {
  # parameter = vector of parameters for which to make the plot
  # input = a matrix of PSA runs for all the parameters
  # he = a bcea object with the economic evaluation
  # wtp = a willingness-to-pay threshold (default at the break even point from he)
  # ... extra arguments including
  #     xlim = x-axis limits
  #     ca = cex axis label (default = 0.7)
  #     cn = cex names label (default = 0.7)
  #     mai = graphical parameter to determine the margins
  #     rel = if TRUE (default) then shows a plot of EVPPI/EVPI, if FALSE then only EVPPI
  #     N = number of PSA to be used to perform the evppi analysis
  
  # Function to actually create the bar plot
  make.barplot <- function(scores,chk2,xlab,xlim,ca,cn,mai,space) {
    col <- rep(c("blue","red"),length(chk2))
    par(mai=mai)
    res <- data.frame(parameter=names(chk2),info=scores,row.names=NULL)
    barplot(res[order(res$info),2],horiz=T,names.arg=res[order(res$info),1],cex.names=cn,las=1,col=col,cex.axis=ca,
            xlab=xlab,space=space,main=tit,xlim=xlim)
    par(mai=c(1.360000,1.093333,1.093333,0.560000))
    list(rank=data.frame(parameter=res[order(-res$info),1],info=res[order(-res$info),2]))
  }
  
  # Prevents BCEA::evppi from throwing messages
  quiet <- function(x) { 
    sink(tempfile()) 
    on.exit(sink()) 
    invisible(force(x)) 
  } 
  
  exArgs <- list(...)
  if(is.null(wtp)){wtp=he$k[min(which(he$k>=he$ICER))]}
  
  if(class(parameter[1])=="character"){
    parameters<-array()
    for(i in 1:length(parameter)){
      parameters[i]<-which(colnames(input)==parameter[i])
    }
  }else{
    parameters=parameter
  }
  parameter=colnames(input)[parameters]
  
  # needs to exclude parameters with weird behaviour (ie all 0s)
  w <- unlist(lapply(parameter,function(x) which(colnames(input)==x)))
  if(length(w)==1){
  } else {
    input <- input[,w]
    chk1 <- which(apply(input,2,var)>0)   # only takes those with var>0
    tmp <- lapply(1:dim(input)[2],function(x) table(input[,x])) # check those with <5 possible values (would break GAM)
    chk2 <- which(unlist(lapply(tmp,function(x) length(x)>=5))==TRUE)
    names(chk2) <- colnames(input[,chk2])
    
    # Can do the analysis on a smaller number of PSA runs
    if(exists("N",where=exArgs)) {N <- exArgs$N} else {N <- he$n.sim}
    if(any(!is.na(N)) & length(N)>1) {
      select <- N
    } else {
      N <- min(he$n.sim,N,na.rm=T)
      if(N==he$n.sim) {select <-1:he$n.sim} else {select <- sample(1:he$n.sim,size=N,replace=F)} 
    }
    m <- he; m$k=wtp
    x <- list()
    for (i in 1:length(chk2)) {
      x[[i]] <- quiet(evppi(parameter=chk2[i],input=input,he=m,N=N))
    }
    scores <- unlist(lapply(x,function(x) x$evppi/x$evi[which(he$k==wtp)]))
    # Optional inputs
    if(exists("ca",where=exArgs)) {ca <- exArgs$ca} else {ca <- .7}
    if(exists("cn",where=exArgs)) {cn <- exArgs$cn} else {cn <- .7}
    xlab <- "Proportion of total EVPI"
    if(exists("rel",where=exArgs)) {
      if (exArgs$rel==FALSE) {
        scores <- unlist(lapply(x,function(x) x$evppi))
        xlab <- "Absolute value of the EVPPI"
      }
    }
    if(exists("xlim",where=exArgs)) {xlim=exArgs$xlim} else {xlim=c(0,range(scores)[2])}
    if(exists("mai",where=exArgs)) {mai=exArgs$mai} else {mai=c(1.36,1.5,1,1)}
    if(exists("tit",where=exArgs)) {tit=exArgs$tit} else {tit <- paste0("Info-rank plot for willingness to pay=",wtp)}
    if(exists("space",where=exArgs)) {space=exArgs$space} else {space=.5}
    
    # Makes the plot
    make.barplot(scores=scores,chk2=chk2,xlab=xlab,xlim=xlim,ca=ca,cn=cn,mai=mai,space) 
  }
}
