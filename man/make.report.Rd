% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make.report.R
\name{make.report}
\alias{make.report}
\title{make.report}
\usage{
make.report(he, evppi = NULL, ext = "pdf", echo = FALSE, ...)
}
\arguments{
\item{he}{An object obtained as output to a call to \code{bcea}}

\item{evppi}{An object obtained as output to a call to \code{evppi}
(default is NULL, so not essential to producing the report).}

\item{ext}{A string of text to indicate the extension of the 
resulting output file. Possible options are \code{"pdf"}, \code{"docx"}.
This requires the use of pandoc, knitr and rmarkdown.}

\item{echo}{A string (default to \code{FALSE}) to instruct whether
the report should also include the \code{BCEA} commands used to 
produce the analyses. If the optional argument \code{echo} is set
to \code{TRUE} (default = \code{FALSE}), then the commands are also
printed.}

\item{...}{Additional parameters. For example, the user can specify the
value of the willingness to pay \code{wtp}, which is used in some of
the resulting analyses (default at the break even point). 
Another additional parameter that the user can specify is the name 
of the file to which the report should be written. This can be done 
by simply passing the optional argument \code{filename="NAME"}. 
The user can also specify an object including the PSA simulations 
for all the relevant model parameters. If this is passed to the 
function (in the object \code{psa_sims}),
then \code{make.report} will automatically construct an "Info-rank
plot", which is a probabilistic form of tornado plot, based on the
Expcted Value of Partial Information.  The user can also specify
the optional argument \code{show.tab} (default=FALSE); if set to
\code{TRUE}, then a table with the values of the Info-rank is also
shown.}
}
\description{
Constructs the automated report from the output of the BCEA
}
\examples{
\donttest{
data(Vaccine)
m=bcea(e,c,ref=2)
makeReport(m)
}
}
\references{
Baio, G., Dawid, A. P. (2011). Probabilistic Sensitivity
Analysis in Health Economics.  Statistical Methods in Medical Research
doi:10.1177/0962280211419832.

Baio G. (2012). Bayesian Methods in Health Economics. CRC/Chapman Hall,
London
}
\seealso{
\code{\link{bcea}}
}
\author{
Gianluca Baio
}
\keyword{"Expected}
\keyword{"Health}
\keyword{economic}
\keyword{evaluation",}
\keyword{information"}
\keyword{of}
\keyword{value}
