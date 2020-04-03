#' @title
#'  Connect to a Microsoft SQL Server
#'
#' @family Database
#'
#' @description
#'  Connections to \emph{Microsoft SQL server} are executed on top of
#'  \href{https://www.freetds.org/}{FreeTDS} driver using \emph{sqsh} command line interface
#'  internally. Connections to \emph{Microsoft SQL server} are made each time
#'  the user sends the \emph{SQL}-request. The object created by the function
#'  holds requisites only. So you do not need to disconnect.
#'
#'  Note that \emph{sqsh} client must be installed on the client's system.
#'
#' @param server
#'  client hostname or IP-address. The value is associated with \emph{-H} option
#'  of \emph{sqsh} command.
#'
#' @param user
#'  database username to connect to server. The value is associated with \emph{-U}
#'  option of \emph{sqsh} command.
#'
#' @param domain
#'  user domain name (if any)
#'
#' @param password
#'  password for username required to connect to server. The value is associated
#'  with \emph{-P} option of \emph{sqsh} command.
#'
#' @param tds_version
#'  Set the TDS version to use. Valid versions are \emph{4.0}, \emph{4.2},
#'  \emph{4.6}, \emph{4.9.5}, \emph{5.0}, \emph{7.0} and \emph{8.0}.
#'  The value is associated with \emph{-G} option of \emph{sqsh} command.
#'
#' @details
#'  Do not use domain name in \emph{user}, put it to \emph{domain}.
#'
#' @return
#'  Connection object holding requisites of connection
#'
#' @seealso
#'  \code{\link{mssql}} for sending \emph{SQL-requests}
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

mssql_connection <- function(server = "", domain = "", user="",
                             password = "", tds_version = "8.0"){
  # Assert:
  stopifnot(
    is.character(server), is.character(domain),
    is.character(user), is.character(password),
    is.character(tds_version),

    length(server) + length(domain) + length(user) + length(password) +
      length(tds_version) == 5,
    tds_version %in% c("4.0", "4.2", "4.6", "4.9.5", "5.0", "7.0", "8.0")
  )
  con_attr <- structure(as.list(environment()), class="mssql_connection")
  con_attr$time = Sys.time()
  domain_user_delim <- ifelse(domain == "", "", "\\\\")
  check_code <- 200L  # use common HTML error code here: 200 means OK
  mssql_reply <- tryCatch(
    system(
      sprintf(
        "sqsh -G%s -S%s -U%s%s%s -P%s -C\"SELECT %i\" -mbcp",
        con_attr$tds_version,
        con_attr$server,
        con_attr$domain,
        domain_user_delim,
        con_attr$user,
        con_attr$password,
        check_code
      ),
      intern = TRUE
    )[1],
    error = function(e) NA
  )
  con_attr$status <- !is.na(mssql_reply) &
    typeof(mssql_reply) == "character" &
    mssql_reply == sprintf("%i|", check_code)
  return(con_attr)
}

#' @export
print.mssql_connection <- function(x, ...){
  # S3 method for class 'mssql_connection'
  output <- paste0(
    "Microsoft SQL Server connection",
    "\n-------------------------------",
    "\nConnection try on ", x$time,
    "\n*   Server: ", x$server,
    "\n*     User: ", x$user,
    "\n*   Domain: ", x$domain,
    "\n* Password: ", paste0(rep("*", times= nchar(x$password)), collapse=""),
    "\n*      TDS: ", x$tds_version,
    "\n*   Status: ", ifelse(x$status, "connected", "connection error")
  )
  cat(output)
  invisible(output)
}
