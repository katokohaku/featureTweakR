#' Same function as 'catf()' in BBmisc except for returning [str]
#'
#' @param ...     See \code{\link{sprintf}}
#' @param file    See cat. Default is ""
#' @param append  See cat. Default is FALSE.
#' @param newline Append newline at the end? Default is TRUE.
#'
#' @return a string
#'
#' @export

catf <- function (..., file = "", append = FALSE, newline = TRUE)
{
  msg <- sprintf(...)
  cat(msg, ifelse(newline, "\n", ""),
      sep = "", file = file, append = append)
  invisible(msg)
}

#' Do nothing with any arguments
#'
#' @param ... everything
#'
#' @export

do.nothing <- function(...){}

#' Remove the First or Last n of an Object
#'
#' @param X  a data.frame or a matrix
#' @param n  an integer. number of row to be removed from last. Same as \code{ head(X, NROW(X) - n)}.
#'
#' @examples
#' chop(iris, 140)
#'
#' @export

chop <- function(X, n = 1) {
  if(n > 0) {
    utils::head(X, NROW(X) - n)
  } else {
    utils::tail(X, NROW(X) - abs(n))
  }
}

#' Split dataset into train set and test set (for hold-out)
#'
#' @param dataset  a data.frame or a matrix
#' @param test.ratio  a numelic. Ratio of test data, must be (0, 1).
#'
#' @examples
#' x <- dataSplit(1:10, test.ratio = 0.3)
#' x <- dataSplit(mtcars, test.ratio = 0.3)
#'
#' @export

dataSplit <- function(dataset, test.ratio = 0.1) {
  stopifnot(!missing(dataset), test.ratio > 0, test.ratio < 1)

  n.test <- floor(NROW(dataset) * test.ratio)
  split_data <- list(train = chop(dataset, n.test),
                     test  = tail(dataset, n.test))

  catf("[Split data] train : test = %i : %i obs. (%i colmns)",
       NROW(split_data$train), NROW(split_data$test), NCOL(dataset))
  invisible(split_data)
}


#' Scale a matrix with parameters of a scaled matix
#' @details  X is scaled by \code{center = attr(scaled, "scaled:center")} and \code{scale = attr(scaled, "scaled:scale")}
#'
#' @param X       a matrix or a data.frame to be scaled
#' @param scaled  a scaled matrixa or a scaled data.frame
#'
#' @return        a tibble
#'
#' @examples
#' iris.scaled <- scale(iris[1:100,-5])
#'
#'
#' @export

rescale <- function(X, scaled){
  stopifnot(NCOL(X) == NCOL(scaled))
  scale(X,
        center = attr(scaled, "scaled:center"),
        scale  = attr(scaled, "scaled:scale"))
}

#' Restore a scaled matrix to a matrix with original parameters.
#'
#' @param X         a matrix or a data.frame to be restored
#' @param scaled  a scaled matrixa or a scaled data.frame
#'
#' @return          a tibble
#' @examples
#' iris.scaled <- scale(iris[, -5])
#' descale(head(iris.scaled), iris.scaled)
#' head(iris)
#'
#' @export

descale <- function(X, scaled){
  stopifnot(NCOL(X) == NCOL(scaled))

  purrr::pmap_df( list(a = dplyr::as_data_frame(X),
                b = attr(scaled, "scaled:scale"),
                c=attr(scaled, "scaled:center")),
           function(a, b, c){ a * b + c })
}

