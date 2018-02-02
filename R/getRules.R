#' parse a decision tree in randomForest into list of path as data.frame
#'
#' @param forest  an object of ensemble trees to be parsed. See \code{\link{randomForest}} or \code{\link{xgboost}}.
#' @param ktree   an integer. number of decision tree to be parsed. If ktree=NULL (default), all tree will be parsed.
#' @param resample Logical. If TRUE, trees are ramdomly selected. If FALSE, trees are selected according to head(ktree) from forest.
#'
#' @return        a list of trees (list).
#' @examples
#' \dontrun{
#' X <- iris[, 1:(ncol(iris)-1)]
#' true.y <- iris[, ncol(iris)]
#'
#' rf.iris <- randomForest(X, true.y, ntree=30)
#' getRules(rf.iris, ktree=15)
#' }
#'
#' @export

getRules <- function(forest, ktree=NULL, resample = FALSE){

  all.trees <- NULL
  i.tree <- NULL
  if(class(forest) == "randomForest"){

    if(is.null(ktree)){
      i.tree <- 1:forest$ntree
      catf("extracting all (%i of %i trees)", length(i.tree), forest$ntree)
    } else {
      maxk <- ifelse(ktree > forest$ntree, forest$ntree, ktree)
      if(resample == FALSE){
        i.tree <- 1:maxk
        catf("extracting head(%i) of %i trees", length(i.tree), forest$ntree)
      } else {
        i.tree <- sample(forest$ntree, maxk, replace = FALSE)
        catf("extracting sampled %i of %i trees", length(i.tree), forest$ntree)
      }
    }

    start.time <- Sys.time()
    all.trees <- pforeach::pforeach(k = i.tree, .c=list)({
      featureTweakR:::getRules.randomForest(forest, k=k)
    })
    print(Sys.time() - start.time)
  }
  if(class(forest) == "xgb.Booster"){
    catf("Currently not compatible with xgboost")
  }

  class(all.trees) <- "extractedRules"
  return(all.trees)
}
