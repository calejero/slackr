#' Save R objects to an RData file on Slack
#'
#' \code{save_slackr} enables you upload R objects (as an R data file)
#' to Slack and (optionally) post them to one or more channels
#' (if \code{channels} is not empty).
#'
#' @param ... objects to store in the R data file
#' @param channels Slack channels to save to (optional)
#' @param file filename (without extension) to use
#' @param api_token full API token
#' @param set_locale text encoding value. Default: 'C'
#' @rdname save_slackr
#' @note You can pass in \code{add_user=TRUE} as part of the \code{...} parameters and the Slack API
#'       will post the message as your logged-in user account (this will override anything set in
#'       \code{username})
#' @return \code{httr} response object from \code{POST} call
#' @seealso \code{\link{slackr_setup}}, \code{\link{dev_slackr}}, \code{\link{slackr_upload}}
#' @export
#' @examples \dontrun{
#' slackr_setup()
#' save_slackr(mtcars, channels="#slackr", file="mtcars")
#' }
save_slackr <- function(..., channels="",
                        file="slackr",
                        api_token=Sys.getenv("SLACK_API_TOKEN"),
                        set_locale="C") {


  loc <- Sys.getlocale('LC_CTYPE')
  Sys.setlocale('LC_CTYPE', set_locale)
  on.exit(Sys.setlocale("LC_CTYPE", loc))

  ftmp <- tempfile(file, fileext=".rda")
  save(..., file=ftmp)

  on.exit(unlink(ftmp), add=TRUE)

  modchan <- slackr_chtrans(channels)
  if (length(modchan) == 0) modchan <- ""

  res <-httr::POST(url="https://slack.com/api/files.upload",
                   httr::add_headers(`Content-Type`="multipart/form-data"),
                   body=list(file=httr::upload_file(ftmp),
                             filename=sprintf("%s.rda", file),
                             token=api_token,
                             channels=modchan))

  stop_for_status(res)

  invisible(res)

}
