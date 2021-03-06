# discussion09.R

###################################
# ----- Databases & RSQLite ----- #
###################################

# A database hold one or more tables. Structured 
# query language (SQL) allows us to manipulate
# the database.

# There are several types of databases that 
# support SQL, such as MS Access, MySQL, and
# SQLite. We'll use the latter.

install.packages('RSQLite')

# The R package for working with SQLite is
# RSQLite.

library(RSQLite)

# SQLite databases are stored in a single file,
# typically with a .db extension.

# We can connect to a SQLite database using the
# function dbConnect(), with the format
#
#   dbConnect(TYPE, dbname = FILE)
#
# where TYPE is the type of database, and FILE is
# the path to the database file.

db <- dbConnect('SQLite', dbname = 'suppliers.db')

# When we're done with a database, we can
# disconnect from it with dbDisconnect().

dbDisconnect(db)

# The function dbListTables() returns the names of
# the tables in the database.

dbListTables(db)

# We can query the database using the function
# dbGetQuery(), which has format
#
#   dbGetQuery(DATABASE, QUERY)
#
# where DATABASE is the connection created with
# dbConnect(), and QUERY is an SQL query.

##########################
# ----- Selections ----- #
##########################

# SQL commands are traditionally written in all
# caps, with a semicolon at the end. Column and
# table names are usually not in caps. However,
# SQL is **not** case-sensitive!

# The most basic command is selection:
#
#   SELECT column FROM table
#
# This selects the specified column(s) from the
# specified table. Use * if you want to select
# all columns.
dbGetQuery(db, 'SELECT * FROM Parts;')

dbGetQuery(db, 'SELECT City, Color FROM Parts;')

# Add LIMIT to the end to limit the number of
# rows returned. This is a good idea if you're
# not sure how big the table is!

dbGetQuery(db, 'SELECT * FROM Parts LIMIT 3;')

# Use SELECT DISTINCT if you only want the 
# distinct values in the column(s).
dbGetQuery(db, 'SELECT DISTINCT Color FROM 
           Parts;')

# On multiple columns, this returns all distinct
# pairs (or tuples).
dbGetQuery(db, 'SELECT DISTINCT City, Color
           FROM Parts;')

# To select only the rows where a column satisfies
# a condition, use 
#
#   SELECT column FROM table WHERE condition
#
# Possible conditions:
#   =, >, >=, <, <=
#   != or <>, meaning 'not equal'

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE Weight > 14;')

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE Color = "Red";')

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE COLOR <> "Red";')

# Another possible condition is that a column
# is within a collection of values:
#
#   column IN (value1, value2, ...)

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE City IN ("London", "Oslo");')

# We might also be interested in a column within
# a range:
#
#   column BETWEEN value1 AND value2
#
# This works for both numbers and text. Inclusive.

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE Weight BETWEEN 13 AND 16;')

# For text columns, we might want to match on
# a pattern:
#
#   column LIKE pattern
#
# SQL pattern syntax is slightly different from
# regular expresions.
#   _ matches any 1 character (cf. '.')
#   % matches 0 or more characters (cf. '.*')

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE City LIKE "L%";')

# Conditionals can also be chained together with
# AND, OR, and NOT.

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE City IN ("London", "Oslo")
           OR Weight = 12;')

# To sort the results, add:
#
#   ORDER BY column1 ASC, column2 DESC, ...
#
# Here ASC means ascending order and DESC means
# descending order. These can be left out; the
# default is ascending order.

dbGetQuery(db, 'SELECT * FROM Parts
           WHERE Weight > 12
           ORDER BY PartName DESC, Weight ASC;')

###############################
# ----- Creating Tables ----- #
###############################

# We can save the results of a query within the
# database by using:
#
#   CREATE TABLE table AS query
#
# where we specify a **new** table name and a
# SELECT query. The new table is not temporary;
# it will stay in the database even if you
# disconnect and reconnect.

dbGetQuery(db, 'CREATE TABLE NewTable AS
           SELECT * FROM Parts
           WHERE Color = "Red";')

dbListTables(db)
dbGetQuery(db, 'SELECT * From NewTable')

# We can delete a table from the database by
# using DROP TABLE. Be careful, there's no undo!

dbGetQuery(db, 'DROP TABLE NewTable;')

dbListTables(db)

##############################
# ----- Joining Tables ----- #
##############################

# Joins allow us to join two tables together.
# The syntax is:
# 
#   SELECT * 
#   FROM table1 AS t1
#   INNER JOIN table2 AS t2
#   ON t1.column1 = t2.column1
#

dbGetQuery(db, 'SELECT * FROM Suppliers;')
dbGetQuery(db, 'SELECT * FROM SupplierParts;')

# An INNER JOIN returns all rows when there is at 
# least one match in both tables.

dbGetQuery(db,'SELECT a.*,
           b.SupplierName, b.Status, b.City
           FROM SupplierParts AS a
           INNER JOIN Suppliers AS b
           ON a.SupplierID = b.SupplierID;')

# LEFT JOIN: Return all rows from the left table,
# and the matched rows from the right table

dbGetQuery(db,'SELECT a.*,
           b.SupplierName, b.Status, b.City
           FROM SupplierParts AS a
           LEFT JOIN Suppliers AS b
           ON a.SupplierID = b.SupplierID;')

dbGetQuery(db,'SELECT a.*,
           b.PartID, b.Qty
           FROM Suppliers AS a
           LEFT JOIN SupplierParts AS b
           ON a.SupplierID = b.SupplierID;')

# Many SQL databases also support RIGHT JOIN
# and FULL JOIN. However, SQLite does not.

####################################
# ----- Functions & Grouping ----- #
####################################

# SQL has several built-in functions:
#   AVG()
#   COUNT()
#   MAX(), MIN()
#   SUM()
# There are also others.

dbGetQuery(db, 'SELECT AVG(Weight) FROM Parts;')
dbGetQuery(db, 'SELECT AVG(Weight) AS Mean
           FROM Parts;')

dbGetQuery(db, 'SELECT MAX(Weight) FROM Parts;')

dbGetQuery(db, 'SELECT SUM(Weight) FROM Parts;')

# These can also be grouped by a column using:
#
#   GROUP BY column

dbGetQuery(db, 'SELECT City, COUNT(*) FROM Parts
           GROUP BY City;')

# If you want to use a condition on an SQL
# function, you must use HAVING instead of WHERE.

dbGetQuery(db, 'SELECT SupplierID, SUM(Qty) 
           FROM SupplierParts 
           GROUP BY SupplierID 
           HAVING SUM(Qty) > 500;')

dbDisconnect(db)

#######################################
# ----- More On Creating Tables ----- #
#######################################

# We can create a table in memory by using the
# special dbname setting ':memory:'.
db <- dbConnect('SQLite', dbname = ':memory:')

# Create a table with the command:
#
#   CREATE TABLE name (
#     column1_name type,
#     column2_name type,
#     ...
#   );
#
# The basic data types are in SQLite are:
#   integer   - an integer
#   real      - a floating point (real) number
#   text      - a text string
#   blob      - binary data
#   boolean   - a true/false value
#   date      - a date

query <- '
CREATE TABLE Suppliers (
  SupplierID integer,
  SupplierName text,
  Status integer,
  City text,
  PRIMARY KEY(SupplierID)
);'
dbGetQuery(db, query)

data <- data.frame(SupplierID = 1:5,
                   SupplierName = c('Smith', 
                                    'Jones',
                                    'Blake', 
                                    'Clark',
                                    'Adams'),
                   Status = c(20, 10, 30, 20, 30),
                   City = c('London', 'Paris', 
                            'Paris', 'London',
                            'Athens'))
data
dbWriteTable(db, 'Suppliers', data, append = TRUE,
             row.names = 0)

query <- '
CREATE TABLE Parts (
  PartID integer,
  PartName text,
  Color text,
  Weight real,
  City text,
  PRIMARY KEY(PartID)
);'
dbGetQuery(db, query)

data <- data.frame(PartID = 1:6,
                   PartName = c('Nut', 'Bolt', 
                                'Screw', 'Screw',
                                'Cam', 'Cog'),
                   Color = c('Red', 'Green', 
                             'Blue', 'Red',
                             'Blue', 'Red'),
                   Weight = c(12.0, 17.0, 17.0,
                              14.0, 12.0, 19.0),
                   City = c('London', 'Paris',
                            'Oslo', 'London',
                            'Paris', 'London'))
data
dbWriteTable(db, 'Parts', data, append = TRUE,
             row.names = 0)

query <- '
CREATE TABLE SupplierParts (
  PartID integer,
  SupplierID integer,
  Qty integer,
  PRIMARY KEY(PartID, SupplierID)
);'
dbGetQuery(db, query)

data <- data.frame(SupplierID = c(rep(1, 6), 2, 2,
                                  3, rep(4, 3)),
                   PartID = c(1:6, 1, rep(2, 3), 
                              4, 5),
                   Qty = c(300, 200, 400, 200,
                           100, 100, 300, 400,
                           200, 200, 300, 400))
data
dbWriteTable(db, 'SupplierParts', data, 
             append = TRUE, row.names = 0)

# We can write a table to a database file using
# sqliteCopyDatabase(). Beware, this will
# overwrite the file without asking!

sqliteCopyDatabase(db, 'suppliers.db')

dbDisconnect(db)
