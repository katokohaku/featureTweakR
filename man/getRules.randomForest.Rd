% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getRules.randomForest.R
\name{getRules.randomForest}
\alias{getRules.randomForest}
\title{parse a decision tree in randomForest into list of path as data.frame}
\usage{
getRules.randomForest(forest, k = 1, label.to = NULL)
}
\arguments{
\item{forest}{a randomForest object to be parsed}

\item{k}{an integer. k-th decision tree in forest will be parsed.}

\item{label.to}{A character.}
}
\value{
a list of rules (data.frame), separated by class label of leaf.
}
\description{
parse a decision tree in randomForest into list of path as data.frame
}
\examples{
\dontrun{
X <- iris[, 1:(ncol(iris)-1)]
true.y <- iris[, ncol(iris)]

rf.iris <- randomForest(X, true.y, ntree=30)
getRules.randomForest(rf.iris, k=1)
getRules.randomForest(rf.iris, k=1, label.to = "virginica")
}

}
