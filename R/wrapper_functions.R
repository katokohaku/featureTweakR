#' TBD
#'
#' @param X.train  .
#' @param true.y  .
#' @param ntree  .
#' @param epsiron  .
#' @param type  .
#' @param .tryModel  .
#'
#' @export

learnModel <- function(
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
              esatisfy = es)

  class(obj) <- "modelTweakFeature"
  invisible(obj)
}


#' TBD
#'
#' @param object .
#' @param ...  .
#' @param newdata  .
#' @param label.from  .
#' @param label.to  .
#'
#' @export

predict.modelTweakFeature <- function(
  object, ..., newdata, label.from, label.to) {

  test.scaled  <- rescale(newdata, scaled = esInstance$scaled)

  tweaked <- tweak(esrules = esInstance$esatisfy,
                   forest = esInstance$forest,
                   newdata= test.scaled,
                   label.from = label.from, label.to = label.to,
                   .dopar = TRUE)

  obj <- list(scaled   = tweaked,
              descaled = descale.tweakedFeature(tweaked, test.scaled),
              label.from = label.from, label.tol = label.to,
              target   = which(tweaked$predict == label.from))

  class(obj) <- "featureTweak"
  invisible(obj)
}


#' TBD
#'
#' @param x  .
#' @param ...  .
#' @param k  .
#' @param type  .
#'
#' @export


plot.featureTweak <- function(x, ..., k = NULL, type = "frequency"){
  stopifnot(!missing(x))
  pp <- NULL
  if( is.numeric(k) && k > 0){
    # plot suggestion for each instance
    if(k %in% x$target){
      pp <- plotSuggest(x$scaled, k = k, ...)
    } else {
      .mes <- catf("instance[%i] was not predicted as \"%s\"", k, x$label.from)
    }
  } else {
    pp <- plot(x$scaled, type = type)
  }
  invisible(pp)
}
