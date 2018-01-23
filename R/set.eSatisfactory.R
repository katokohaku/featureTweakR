# get e-satisfactory instance of aim-leaf from all tree
#' parse a decision tree in randomForest into list of path as data.frame
#'
#' @param forest  a randomForest object to be parsed
#' @param ntree   an integer. number of decision tree to be parsed. If ntree=NULL (default), all tree will be parsed.
#' @param resample Logical. If TRUE, trees are ramdomly selected. If FALSE, trees are selected according to head(ntree) from forest.
#' @param epsiron a numeric. Amount of "tolerance". All standardized feature value changes from threashold with this tolerance.
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
#' @importFrom pforeach pforeach npforeach
#' @importFrom magrittr %>%
#' @importFrom purrr map
#' @importFrom dplyr mutate select
#'
#' @export
set.eSatisfactory <- function(forest, ntree=NULL, resample = FALSE, epsiron = 0.1) {
  stopifnot(epsiron > 0)

  all.trees <- getRules(forest, ntree=ntree, resample=resample)
  stopifnot(! is.null(all.trees))

  catf("set e-satisfactory instance (%i trees)", length(all.trees))
  start.time <- Sys.time()
  all.eTrees <- pforeach::pforeach(tree.rules = all.trees, .c=list)({
    tree.eRules <- NULL
    for(cn in names(tree.rules)){
      tree.eRules[[cn]] <- map(
        tree.rules[[cn]]$path,
        function(obj){
          mutate(obj,
                 eps = ifelse(lr=="<", -epsiron, +epsiron),
                 e.satisfy = point + eps) %>%
            select(-node, -path.to)
        }
      )
    }
    return(tree.eRules)
  })
  print(Sys.time() - start.time)

  esforest <- list(forest = forest, trees = all.eTrees)
  class(esforest) <- "forest.eSatisfactoryRules"
  invisible(esforest)
}
