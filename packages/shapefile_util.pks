create or replace PACKAGE "SHAPEFILE_UTIL" is
  --------------------------------------------------------------------------------
  -- Module   : $HeadURL: svn://b2imimcf@gis.mvn.usace.army.mil/sandp/DatabaseScripts/ShapefileComponent/trunk/packages/shapefile_util.pks $
  -- Author   : grep
  -- Date     : $Date: 2024-10-03 14:31:37 -0500 (Thu, 03 Oct 2024) $
  -- Revision : $Revision: 19582 $
  -- Requires : Types shapefile, shapefile_t, and shapefile_tab
  -- Usage    : Functions to access data from shapefiles. Whereas
  --            the Shapefile type is used in plsql to iterate over 
  --            the features in a shapefile. The ShapefileTable functions
  --            can be used directly in sql.
  -- Notes    : Version 1.1 - Added support for reading dbase (dbf files with no
  --            associated shp file). These are treated as shapefiles with
  --            no geometry.
  --        
  --            Version 1.2 Added GetFeatureCount function. ListFeatureClasses,
  --            ListFields, and GetFeatureCount now works even if the .prj file
  --            is missing or unrecognized. 
  --------------------------------------------------------------------------------
  
  m_majorVersion constant number := 1;
  m_minorVersion constant number := 2;
  
  -- Return a string of all featureclasses in the input shapefile zip, p_shapefilezip.
  -- A featureclass is .shp file without the .shp extension. If the .shp file is
  -- in a directory in the zip file, then the full path of that directory is included
  -- in the featureclass name.
  -- The string is delimited by the input delimiter, p_delimiter. The optional parameter, p_shapetype,
  -- is used to filter the list of featureclases based on geometry type. If used, it must be one of the 
  -- following values: [Point, Line, Polygon, Multipoint]. 
  --
  -- Implementation note: If the p_shapetype parameter is used, this function 
  -- will instantiate a Shapefile instance for each .shp file in the zip. 
  --
  -- Example Usage:
  --   select z.column_name from apex_application_temp_files f 
  --   inner join table(apex_string.split(shapefile_util.listfeatureclasses(f.blob_content), ',')) z
  --   on name = :FILENAME
  function ListFeatureClasses(p_shapefilezip in blob, p_shapetype in varchar2 default null, p_delimiter in varchar2 default ',') return varchar2;
  -- Return a table of objects representing the field types of the shapefile in the zip, p_shapefilezip.
  -- If there is more than one shapefile in the zip, then the feature class, p_featureclass must be specified.
  -- Each object contains the following fields:
  --  
  --   name         : field name
  --   fieldType    : DBase III field data type. C = string, D = YYYYMMDD format date, N, I, F, O = numeric
  --   fieldLength  : maximum number of characters in the field.
  --   decimalCount : number of decimal places for numeric value if the field is numeric.
  function ListFields(p_shapefilezip in blob, p_featureclass in varchar2 default null) return ShapefileDBFFieldList;
  
  -- Return the number of features (or rows) shapefile in the zip, p_shapefilezip.
  -- If there is more than one shapefile in the zip, then the feature class, p_featureclass must be specified.
  function GetFeatureCount(p_shapefilezip in blob, p_featureclass in varchar2 default null) return integer;
  
  -- Return the Spatial Reference Id (SRID) of the shapefile in the zip, p_shapefilezip based on the shapefile
  -- .prj file component. Since ESRI and Oracle use different naming conventions, this function shall attempt to
  -- lookup the SRID from the WELLKNOWN_COORDSYS_NAME in the ORACLE_SRID_XREF table.
  -- If there is more than one shapefile in the zip, then the feature class, p_featureclass must be specified.
  function GetSpatialReferenceId(p_shapefilezip in blob, p_featureclass in varchar2 default null) return integer;
  
  -- Given an input zipfile, p_shapefilezip, that may contain multiple shapefiles, 
  -- return a string of sql code that is a call to json_table with the arguments needed to extract all attributes from the input shapefile.
  -- A developer can use this function on sample data to save some time writing these shapefile queries.
  -- If p_featureclass is null, assume there is only one featureclass and if there are more than one shapefiles in the zip, raise exception.
  -- If p_srid is null and the prj is missing or invalid, raise exception.
  function GenerateJSONQuery(p_shapefilezip in blob, p_srid in integer default null, p_featureclass in varchar2 default null, p_blobname in varchar2) return varchar2;
  
  -- Given an input zipfile, p_shapefilezip, containing a single shapefile, 
  -- return a collection of shapefile features using the coordinate system reference provided by the included prj file.
  -- If there are more than one shapefiles in the zip, raise exception.
  -- If the prj is missing or invalid, raise exception.
  -- If the shapefile has z values, assume the vertical datum is NAVD88 and the vertical units are FEET.
  function ShapefileTable(p_shapefilezip in blob) return shapefile_tab;
  -- Given an input zipfile, p_shapefilezip, containing a single shapefile, 
  -- return a collection of shapefile features using the coordinate system reference associated with SRID in p_srid argument,
  -- ignoring any included prj file. SRID lookup uses the ORACLE_SRID_XREF table.
  -- If there are more than one shapefiles in the zip, raise exception.
  function ShapefileTable(p_shapefilezip in blob, p_srid in integer) return shapefile_tab;
  -- Given an input zipfile, p_shapefilezip, that may contain multiple shapefiles, 
  -- return a collection of shapefile features using the shapefile with in the input featureclass name, p_featureclass 
  -- and the coordinate system reference provided by the included prj file.
  -- The featureclass is the shapefile filename with the full zip path, but without the extention.
  -- If the prj is missing or invalid, raise exception.
  -- If the shapefile has z values, assume the vertical datum is NAVD88 and the vertical units are FEET.
  function ShapefileTable(p_shapefilezip in blob, p_featureclass in varchar2) return shapefile_tab;
  -- Given an input zipfile, p_shapefilezip, that may contain multiple shapefiles, 
  -- return a collection of shapefile features using the shapefile with in the input featureclass name, p_featureclass.
  -- The featureclass is the shapefile filename with the full zip path, but without the extention.
  -- If p_featureclass is null, assume there is only one featureclass and if there are more than one shapefiles in the zip, raise exception.
  -- If p_srid is null, use the coordinate system reference provided by the included prj file and if the prj is missing or invalid, raise exception.
  -- If the shapefile has z values and no p_srid is specified, then lookup the coordinate reference system in oracle_3d_srid_xref table , using the
  -- p_vertical_datum and p_vertical_units arguments.
  function ShapefileTable(p_shapefilezip in blob, p_srid in integer, p_featureclass in varchar2, p_vertical_datum in varchar2 default 'NAVD88', p_vertical_units in varchar2 default 'FEET') return shapefile_tab;
  -- Given a ShapefileReader instance, return a piped iterator of shapefile features.
  function ShapefileTablePipe(p_shapefile in ShapefileReader) return shapefile_tab pipelined;
  
  -- Given an input zipfile, p_shapefilezip, that may contain multiple shapefiles, 
  -- return an GeoJSON CLOB representation of shapefile using the shapefile with the input featureclass name, p_featureclass.
  -- The featureclass is the shapefile filename with the full zip path, but without the extention.
  -- The CLOB should be parable with SDO_UTIL.FROM_GEOJSON function.
  -- If p_featureclass is null, assume there is only one featureclass and if there are more than one shapefiles in the zip, raise exception.
  -- If p_srid is null, use the coordinate system reference provided by the included prj file and if the prj is missing or invalid, raise exception.
  function ShapefileJSON(p_shapefilezip in blob, p_srid in integer default null, p_featureclass in varchar2 default null) return clob;
  
  -- Given input select query string, p_query, generate a zipped shapefile blob with filename, p_output_filename.
  -- The query must contain two columns, the first must be be an sdo_geometry or null and the second must be a json
  -- associate array string.
  --
  -- Ex. select shape, json_object('id' value survey_area_id, 'alt_name' value alt_name) attr from survey_areas
  --
  -- Output shapefile columns will be 255 character length strings. 
  function WriteShapefile(p_query in varchar2, p_output_filename in varchar2) return blob;
  
  -- Package metadata functions
  function majorVersion return number;
  function minorVersion return number;
  function LastEditedBy return varchar2;
  function lastModifiedDate return varchar2;
  function revision return varchar2;
  
end;
