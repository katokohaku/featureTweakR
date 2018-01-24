#' calcurate suggention for each inputs based on prediction
#'
#' @param obj
#' @param newdata
#' @param label.from
#' @param lael.to
#' @param .dopar
#'
#' @return        a list of trees (list).
#' @examples
#' \dontrun{
#' X <- iris[, 1:(ncol(iris)-1)]
#' true.y <- iris[, ncol(iris)]
#'
#' rf.iris <- randomForest(X, true.y, ntree=30)
#' es.rf <- set.eSatisfactory(forest.rf, ntree = 30, epsiron = 0.3, resample = TRUE)
#' }
#'
#' @importFrom stats dist predict
#' @importFrom pforeach pforeach npforeach
#'
#' @export

tweak <- function(
  obj, newdata, label.from, label.to, .dopar = TRUE)
{
  stopifnot(class(obj) == "forest.eSatisfactoryRules",
            !missing(newdata), !missing(label.from), !missing(label.to) )

  forest <- obj$forest
  estrees <- obj$trees
  nestree <- length(obj$trees)
  catf("%i instances were predicted by %i trees: ", NROW(newdata), nestree)

  pred.y <- predict(forest, newdata=newdata, predict.all=TRUE)
  pred.Freq <- table(pred.y$aggregate)
  print(pred.Freq)

  .loop <- ifelse(.dopar, pforeach, npforeach)
  start.time <- Sys.time()
  tweak <- .loop(target.instance = 1:length(pred.y$aggregate), .combine = rbind)(
    {
      this.instance  <- newdata[target.instance, ]
      this.aggregate <- pred.y$aggregate[target.instance]
      tree.predict   <- pred.y$individual[target.instance, 1:nestree]
      tree.agreed    <- which(tree.predict == this.aggregate )

      catf("instance[%i]: predicted \"%s\" (wants \"%s\"->\"%s\")",
           target.instance, this.aggregate, label.from, label.to)

      tweaked.instance <- this.instance
      delta.min <- 0

      if(this.aggregate == label.to){
        catf("- SKIP")
      } else {
        cand.eSatisfy <- npforeach(i.tree = tree.agreed)(
          estrees[[i.tree]][[label.to]]
        )
        catf("- evalutate %i candidate of rules", length(estrees))

        delta.min <- 1e+99

        for(this.path in cand.eSatisfy){

          this.tweak <- this.instance
          for(ip in 1:NROW(this.path)){
            feature <- as.character(this.path[ip, ]$split.var)
            this.tweak[feature] <- this.path[ip, ]$e.satisfy
          }
          delta <- dist(rbind(this.instance, this.tweak))

          if(delta < delta.min){
            if(predict(forest, newdata=this.tweak) == label.to){
              tweaked.instance <- this.tweak
              delta.min <- delta
            }
          }
        }
      }
      return(tweaked.instance)
    }
  )
  print(Sys.time() - start.time)
  all.tweak <- list(predict = pred.y$aggregate, original = newdata, suggest = tweak)
  class(all.tweak) <- "tweaked.suggestion"
  return(all.tweak)
}
