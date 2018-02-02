#' Calcurate suggention for each inputs based on prediction
#'
#' @param esrules an object returned by set.eSatisfactory().
#' @param newdata a data.frame or matrix. test data to be predicted and to be suggested. newdata must have the same structure of train data.
#' @param label.from a character. Predicted class label that user wants to change.
#' @param label.to a character. Class label that user wants to be changed from \code{label.from}.
#' @param .dopar logical. If \code{.dopar = TRUE}, suggestion for each instance will be calculated in parallel
#'
#' @return a list of
#' \itemize{
#'  \item{"predict"}{ character vector of predicted label of each instance. See \code{\link{predict.randomForest}}. }
#'  \item{"original"}{ is the same as \code{newdata}. }
#'  \item{"suggest"}{ a data.frame of instances tweakd from newdata. }
#' }
#'
#' @examples
#' \dontrun{
#' X <- iris[, 1:(ncol(iris)-1)]
#' true.y <- iris[, ncol(iris)]
#'
#' rf.iris <- randomForest(X, true.y, ntree=30)
#' es.rf <- set.eSatisfactory(forest.rf, ntree = 30, epsiron = 0.3, resample = TRUE)
#' tweaked <- tweak(es.rf, newdata= X.test, label.from = "spam", label.to = "nonspam",
#'                  .dopar = TRUE)
#' }
#'
#' @export

tweak <- function(
  esrules, newdata, label.from, label.to, .dopar = TRUE)
{
  stopifnot(class(esrules) == "forest.eSatisfactoryRules",
            !missing(newdata), !missing(label.from), !missing(label.to) )

  forest  <- esrules$forest
  estrees <- esrules$trees
  nestree <- length(esrules$trees)
  catf("%i instances were predicted by %i trees: ", NROW(newdata), nestree)

  pred.y  <- stats::predict(forest, newdata=newdata, predict.all=TRUE)
  pred.Freq <- table(pred.y$aggregate)
  print(pred.Freq)

  .loop <- ifelse(.dopar, pforeach::pforeach, pforeach::npforeach)
  start.time <- Sys.time()
  tweak <- .loop(target.instance = 1:length(pred.y$aggregate), .combine = rbind)(
    {
      this.instance  <- newdata[target.instance, ]
      this.aggregate <- pred.y$aggregate[target.instance]
      tree.predict   <- pred.y$individual[target.instance, 1:nestree]
      tree.agreed    <- which(tree.predict == this.aggregate )

      catf("instance[%i]: predicted \"%s\" agreed by %i tree (wants \"%s\"->\"%s\")",
           target.instance, this.aggregate, length(tree.agreed), label.from, label.to)

      tweaked.instance <- this.instance
      delta.min <- 0

      if(this.aggregate == label.to){
        catf("- SKIP")
      } else {
        cand.eSatisfy <- pforeach::npforeach(i.tree = tree.agreed)(
          estrees[[i.tree]][[label.to]]
        )
        catf("evaluate %i rules in %i trees",
             length(cand.eSatisfy), length(tree.agreed))

        delta.min <- 1e+99
        for(this.path in cand.eSatisfy){

          this.tweak <- this.instance
          for(ip in 1:NROW(this.path)){
            feature <- as.character(this.path[ip, ]$split.var)
            this.tweak[feature] <- this.path[ip, ]$e.satisfy
          }

          delta <- stats::dist(rbind(this.instance, this.tweak))
          if(delta < delta.min){
            if(stats::predict(forest, newdata=this.tweak) == label.to){
              tweaked.instance <- this.tweak
              delta.min <- delta
            }
          }
        }
        catf("- evalutate %i candidate of rules (delta.min=%.3f)",
             length(estrees), delta.min)
      }

      return(tweaked.instance)
    }
  )
  print(Sys.time() - start.time)
  all.tweak <- list(predict = pred.y$aggregate,
                    original = newdata,
                    suggest = tweak)
  class(all.tweak) <- "tweaked.suggestion"
  return(all.tweak)
}
