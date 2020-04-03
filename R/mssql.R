#' @title
#'  Get response from Microsoft SQL Server
#'
#' @family Database
#'
#' @description
#'  Send \emph{SQL}-query and get server response as \emph{data.table}
#'
#' @param con
#'  connection object of class \code{\link{mssql_connection}}
#'  of \emph{sqsh} command.
#'
#' @param query
#'  valid \emph{SQL}-expression as character
#'
#' @details
#'  Connection problems are mostly processed and diagnostics is returned as
#'  \emph{data.table}. Error codes are \emph{HTTP} status codes.
#'
#' @return
#'  \emph{Microsoft SQL server} response as \emph{data.table}
#'
#' @seealso
#'  \code{\link{mssql_connection}} for creating connection object
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Create connection object:
#' conn <- mssql_connection(server = "10.100.104.142", domain = "SUEK",
#'  user = "user", password = "password")
#'
#' # Ask for data:
#'  mssql(conn, "SELECT 200 AS V1, 300 AS V2")
#'
#' # Output:
#'  #     V1  V2
#'  # 1: 200 300
#' }
mssql <- function(con,
                  query = "SELECT 200 AS Response, CURRENT_TIMESTAMP AS Relevance"){
  # Send SQL query to Microsoft SQL server

  # Asserts
  stopifnot(
    class(con) == "mssql_connection",
    length(query) < 2, is.character(query)
  )

 if (!con$status)
   return(data.table::as.data.table(list(Response = 404, Relevance = con$time)))

  domain_user_delim <- ifelse(con$domain == "", "", "\\\\")
  mssql_reply <-
    tryCatch(
      system(
        sprintf(
          "sqsh -G%s -S%s -U%s%s%s -P%s -mcsv -Ldatetime=\"%%Y-%%m-%%d %%H-%%M-%%S\" -C\"%s\"",
          con$tds_version,
          con$server,
          con$domain,
          domain_user_delim,
          con$user,
          con$password,
          query
        ),
        intern = TRUE
      ),
      error = function(e)
        c("Response,Relevance", sprintf("\"503\",\"%s\"", Sys.time()))
    )
  return(
    data.table::fread(
      text = gsub("(\\d),(\\d)", "\\1.\\2", mssql_reply)))
}