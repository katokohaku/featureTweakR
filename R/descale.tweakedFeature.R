#' Restore tweaked instances to the original scale
#'
#' @param tweaked.X  an object returned by tweak() to be restored.
#' @param scaled.X  a scaled matrixa or a scaled data.frame. Usually train set or test set.
#'
#' @return a list of
#' \itemize{
#'  \item{"original"}{ a data.frame of the same instances before being scalsed. }
#'  \item{"suggest"}{ a data.frame of instances tweakd in original scale. }
#'  \item{"diff"}{ a tibble of \code{(suggest - original)} }
#' }
#'
#' @examples
#' \dontrun{
#' X <- iris[, 1:(ncol(iris)-1)]
#' scaled.X <- scale(X)
#' true.y <- iris[, ncol(iris)]
#'
#' rf.iris <- randomForest(scaled.X, true.y, ntree=30)
#' es.rf <- set.eSatisfactory(forest.rf, ntree = 30, epsiron = 0.3, resample = TRUE)
#' tweaked <- tweak(es.rf, newdata= scaled.X, label.from = "spam", label.to = "nonspam",
#'                  .dopar = TRUE)
#' dt <- descale.tweakedFeature(tweaked, scaled.X)
#' }
#'
#' @export

descale.tweakedFeature <- function(tweaked.X, scaled.X){
  stopifnot(class(tweaked.X) == "tweaked.suggestion", !missing(scaled.X))
  original <- descale(tweaked.X$original, scaled.X)
  suggest  <- descale(tweaked.X$suggest, scaled.X)

  return(list(original = original,
              suggest = suggest,
              diff = tibble::as.tibble(suggest - original)) )
}
