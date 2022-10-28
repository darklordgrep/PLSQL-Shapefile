# ![Logo](https://raw.githubusercontent.com/darklordgrep/PLSQL-Shapefile/main/shapfile_logo.png) PLSQL Shapefile 

## Overview
The PLSQL Shapefile Component consists of utilities for reading and writing shapefiles. The shapefile is a file format commonly used in GIS software such as ArcGIS and Geomedia. 

## Installation
To install the Shapefile component, run the scripts in the following order:

1. oracle_srid_xref.sql
2. oracle_3d_srid_xref.sql
3. shapefiletypes.typ
4. shapefile_reader.typ
5. shapefile_reader.tyb
6. shapefile_writer.typ
7. shapefile_writer.tyb
8. shapefile_util.pks
9. shapefile_util.pkb

Alternately, if you can install the testing and demonstration application, shapefile_demo_application.sql, which includes these scripts. Application Express, version 21.1 or later is required.

## Usage 
See shapefile_reader.typ, shapefile_write.typ, and shapefile_util.pks for usage information.

## Testing
The [utPLSQL](https://github.com/utPLSQL/utPLSQL) library is required for testing. To test PL/SQL Shapefile, install the APEX application, shapefile_demo_application.sql. It includes the same test data in the file, shapefile_util_testdata.zip. There is a Testing tab for running unit tests.


