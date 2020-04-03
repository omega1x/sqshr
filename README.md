sqshr - R package to coonect to Microsoft SQL Server for Linux users
--------------------------------------------------------------------

There are some inconveniences when you come to communicate with
*Microsoft SQL server* as a *Linux* client especially in corporate
environment. Due to obscure in security details and corporate
infrastructure
[DBI](https://cran.r-project.org/web/packages/DBI/index.html) and
[odbc](https://cran.r-project.org/web/packages/odbc/index.html) often do
not work from scratch in *Linux*. That is why
[FreeTDS](https://www.freetds.org/) is commonly used (see
[pymssql](https://pypi.org/project/pymssql/) for example).
[Sqsh](https://manpages.debian.org/testing/sqsh/sqsh.1.en.html) in Linux
is a well-known command-line tool leveraging
[FreeTDS](https://www.freetds.org/) for communication with *Microsoft
SQL server*. *Sqshr* is a tiny *R* tool built on top of
[Sqsh](https://manpages.debian.org/testing/sqsh/sqsh.1.en.html).

### Installation

First install
[Sqsh](https://manpages.debian.org/testing/sqsh/sqsh.1.en.html) in your
*Linux* system using appropriate method for your system. In
*Debian*/*Ubuntu* it looks like

    > sudo apt install sqsh

No additional configuration for
[Sqsh](https://manpages.debian.org/testing/sqsh/sqsh.1.en.html) is
required.

Now install *sqshr* package in *R* using
[devtools](https://cran.r-project.org/web/packages/devtools/index.html)
as it commonly
[used](https://cran.r-project.org/web/packages/githubinstall/vignettes/githubinstall.html):

    options("download.file.method" = "libcurl")  # avoid rare problems with devtools
    library(devtools)
    devtools::install_github("omega1x/sqshr")

### Usage

The usage of *sqshr* is very straightforward and implies two steps - (1)
creation of connection object and (2) sending the SQL-query:

    library(sqshr)
    # Create connection object:
    conn <- mssql_connection(server = "11.100.104.142", domain = "SUEKCORP",
     user = "user", password = "password")

    # Ask for data:
     data <- mssql(conn, "SELECT 200 AS V1, 300 AS V2")
     print(data)

    ##     V1  V2
    ## 1: 200 300
