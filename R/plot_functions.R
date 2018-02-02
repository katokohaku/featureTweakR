#' Plot statistics for suggestion of tweaked instances (population)
#'
#' @param x  an object returned by tweak().
#' @param ... Other arguments passed on to methods. Not currently used.
#' @param type what type of plot should be drawn. Possible types are
#' \itemize{
#'  \item{"absoluteSum"}{ draw baplot for absolute sum of suggestions. }
#'  \item{"direction"}{ draw boxplot for suggestions among instances. }
#'  \item{"frequency"}{ draw baplot for total number of tweaked among instances. }
#' }
#'
#' @return a list of
#' \itemize{
#'  \item{"stats"}{ a data.frame of statistics for each feature. }
#'  \item{"plot"}{ a ggplot object (for replot). }
#' }
#'
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
#' plot(tweaked, "a")
#' plot(tweaked, "d")
#' plot(tweaked, "f")
#'
#' }
#'
#' @importFrom magrittr %>%
#' @importFrom ggplot2 ggplot aes geom_bar geom_hline geom_boxplot
#' @importFrom ggplot2 labs coord_flip
#'
#' @export

plot.tweaked.suggestion <- function(
  x, ..., type = c( "absoluteSum", "direction", "frequency"))
{
  stopifnot(class(x) == "tweaked.suggestion")

  type <- match.arg(type)
  print(type)
  tw.diff <- data.frame(x$suggest - x$original)
  pos <- which(rowSums(abs(tw.diff)) > 0)
  if(length(pos) > 0){
    tw.diff <-   tw.diff[pos, ]
  }

  stats <- data.frame(variable=colnames(tw.diff), value=colMeans(abs(tw.diff)))
  p <- stats %>%
    ggplot(aes(x = stats::reorder(variable, value), y = value)) +
    geom_bar(stat = "identity") +
    labs(x = "", y = "mean absolute effort") +
    coord_flip()

  if(type == "direction"){
    stats <- data.frame(variable=colnames(tw.diff),
                        mean=t(dplyr::summarize_all(tw.diff, mean)),
                        median=t(dplyr::summarize_all(tw.diff, mean)))
    stats <- dplyr::arrange(stats, variable)

    p <-  tidyr::gather(tw.diff) %>%
      dplyr::mutate(variable = as.factor(key)) %>%
      ggplot(aes(x = variable, y = value)) +
      geom_hline(yintercept = 0, colour = "red", size = 1.5) +
      geom_boxplot() +
      labs(x = "", y = "All direction of tweak") +
      coord_flip()
  }

  if(type == "frequency"){
    stats <- data.frame(variable = colnames(tw.diff), nonZero = colMeans(tw.diff != 0))
    stats <- dplyr::arrange(stats, -nonZero)
    p <- stats %>%
      ggplot(aes(x = stats::reorder(variable, nonZero), y = nonZero)) +
      geom_bar(stat = "identity") +
      labs(x = "", y = "non-zerp frequency of feature tweaking") +
      coord_flip()
  }

  rownames(stats) <- NULL
  print(stats)
  print(p)

  invisible(list(stats = stats, plot = p))
}


#' Plot individual suggestion (direction to modify)
#'
#' @param x  an object returned by tweak().
#' @param k  an integer. The tweaked direction of k-th instance will be plotted.
#' @param .ordered  a logical. If \code{.ordered = TRUE}, features are sorted by suggestion.
#' @param .nonzero.only  a logical. If \code{.nonzero.only = TRUE}, feature with suggestion = 0 is not shown.
#'
#' @return a ggplot object (for replot).
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
#'
#' plotSuggest(tweaked, k = 1)
#' plotSuggest(tweaked, k = 1, .ordered = TRUE, .nonzero.only = TRUE)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_bar geom_hline ggtitle
#' @importFrom ggplot2 labs coord_flip
#' @export

plotSuggest <- function(x, k = 1, .ordered = FALSE, .nonzero.only = FALSE){

  stopifnot(class(x) == "tweaked.suggestion")
  tw.diff <- data.frame(x$suggest - x$original)

  instance <- tidyr::gather(tw.diff[k, ])
  instance <- dplyr::arrange(instance, key)
  if(.nonzero.only){
    instance <- dplyr::filter(instance, abs(value) > 0)
  }
  p <- ggplot(instance, aes(x=key, y=value))
  if(.ordered) {
    p <- ggplot(instance,
                 aes(x = stats::reorder(key, abs(value)), y=value))
    instance <- dplyr::arrange(instance, abs(value))
  }
  p <- p +
    geom_hline(yintercept=0, colour = "red", size = 1.5) +
    geom_bar(stat = "identity")  +
    ggtitle(catf("instance #%i", k)) +
    labs(x = "", y = "directions of tweak") +
    coord_flip()

  print(p)
  print(instance)

  invisible(p)
}
