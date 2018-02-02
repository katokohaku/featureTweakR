#' Plot statistics for suggestion of tweaked instances (population)
#'
#' @param X.train ,
#' @param true.y ,
#' @param ntree ,
#' @param epsiron ,
#' @param type what type of plot should be drawn. Possible types are
#' \itemize{
#'  \item{"randomForest"}{ set ensemble trees to \code{\link{randomForest}}.}
#'  \item{"xgboost"}{ set ensemble trees to \code{\link{xgboost}}. }
#' }
#' \code{"randomForest"} is defult.
#' @param .tryModel  a logical. If \code{.tryModel = TRUE}, Only build learner.
#'
#' @return a list of
#' \itemize{
#'  \item{"origin"}{ text. }
#'  \item{"scaled"}{ text. }
#'  \item{"forest"}{ text. }
#'  \item{"rules"}{ text. }
#'  \item{"esatisfy"}{ text. }
#' }
#' Default is "absoluteSum".
#'
#' @export

buildInstance <- function(
  X.train, true.y, ntree = 50, epsiron = 0.1,
  type = c("randomForest", "xgboost"), .tryModel = FALSE)
{
  train.scaled <- scale(X.train)

  method <- match.arg(type)
  if(! method == "randomForest"){ stop("Only randomForest") }

  forest <- randomForest::randomForest(train.scaled, true.y, ntree = ntree)
  plot(forest)
  if(.tryModel) { return(forest) }

  print(forest)
  catf("")

  rules <- getRules(forest, ktree = NULL, resample = TRUE)
  es    <- set.eSatisfactory(rules, epsiron = 0.3)

  obj <- list(origin = X.train,
              scaled = train.scaled,
              forest = forest,
              rules = rules,
              esatisfy= es)

  class(obj) <- "buildInstance"
  invisible(obj)
}

