#' parse a decision tree in randomForest into list of path as data.frame
#'
#' @param forest  a randomForest object to be parsed
#' @param ntree   an integer. number of decision tree to be parsed. If ntree=NULL (default), all tree will be parsed.
#' @param resample Logical. If TRUE, trees are ramdomly selected. If FALSE, trees are selected according to head(ntree) from forest.
#'
#' @return        a list of trees (list).
#' @examples
#' \dontrun{
#' X <- iris[, 1:(ncol(iris)-1)]
#' true.y <- iris[, ncol(iris)]
#'
#' rf.iris <- randomForest(X, true.y, ntree=30)
#' getRules(rf.iris, ntree=15)
#' }
#'
#' @importFrom pforeach pforeach

getRules <- function(forest, ntree=NULL, resample = FALSE){

  all.trees <- NULL
  i.tree <- NULL
  if(class(forest) == "randomForest"){

    if(is.null(ntree)){
      i.tree <- 1:forest$ntree
      catf("extracting all (%i of %i trees)", length(i.tree), forest$ntree)
    } else {
      maxk <- ifelse(ntree > forest$ntree, forest$ntree, ntree)
      if(resample == FALSE){
        i.tree <- 1:maxk
        catf("extracting head(%i) of %i trees", length(i.tree), forest$ntree)
      } else {
        i.tree <- sample(forest$ntree, maxk, replace = FALSE)
        catf("extracting sampled %i of %i trees", length(i.tree), forest$ntree)
      }
    }

    start.time <- Sys.time()
    all.trees <- pforeach(k = i.tree, .c=list)({
      getRules.randomForest(forest, k=k)
    })
    print(Sys.time() - start.time)
  }
  if(class(forest) == "xgb.Booster"){
    catf("Currently not compatible with xgboost")
  }

  return(all.trees)
}
