#' get e-satisfactory instance of aim-leaf from all tree
#'
#' @param rules  an objectrandomForest object.
#' @param epsiron a numeric. Amount of "tolerance". All standardized feature value changes from threashold with this tolerance.
#'
#' @return        a list of trees (list).
#' @examples
#' \dontrun{
#' X <- iris[, 1:(ncol(iris)-1)]
#' true.y <- iris[, ncol(iris)]
#'
#' rf.iris <- randomForest(X, true.y, ntree=30)
#' rules.rf <- getRules(rf.iris, ktree = 20)
#' es.rf <- set.eSatisfactory(forest.rf, epsiron = 0.3)
#' }
#'
#' @export

set.eSatisfactory <- function(rules, epsiron = 0.1) {

  stopifnot(class(rules) == "extractedRules", epsiron > 0)

  catf("set e-satisfactory instance (%i trees)", length(rules))
  start.time <- Sys.time()
  esrules <- pforeach::pforeach(tree.rules = rules, .c=list)({
    tree.eRules <- NULL
    for(cn in names(tree.rules)){
      tree.eRules[[cn]] <- purrr::map(
        tree.rules[[cn]]$path,
        function(obj){
          m.obj <- dplyr::mutate(obj,
                 eps = ifelse(lr=="<", -epsiron, +epsiron),
                 e.satisfy = point + eps)
          dplyr::select(m.obj, -node, -path.to)
        }
      )
    }
    return(tree.eRules)
  })
  print(Sys.time() - start.time)

  class(esrules) <- "eSatisfactoryRules"
  invisible(esrules)
}

