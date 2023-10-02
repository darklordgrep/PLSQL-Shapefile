create or replace type ShapefileWriter as object (
  --------------------------------------------------------------------------------
  -- Module   : $HeadURL: svn://gis.mvn.usace.army.mil/sandp/DatabaseScripts/ShapefileComponent/trunk/types/shapefilewriter.typ $
  -- Author   : grep
  -- Date     : $Date: 2023-10-02 12:04:09 -0500 (Mon, 02 Oct 2023) $
  -- Revision : $Revision: 18552 $
  -- Requires : Types ShapefileDBFFieldList, ShapefileDBFField
  -- Usage    : ShapefileWriter writes rows of shapes and atrributes
  --            to a zipfile blob output representing a shapefile.
  --            Example Usage : 
  -- 
  --               shapew := shapefilewriter();
  --               shapew.append(sdo_geometry('Point(-95 33)'), json_object('Id' value 1, 'Name' value 'hi'));
  --               shapew.finish(out_blob, 'outdata');
  --
  -- Notes     : Version 1.0 - Initial release.
  --             Version 1.1 (9/11/2023) - Added the ability to write
  --             shapefiles without geometry as dbase tables. Added
  --             parameter to finish to keep a zipfile open for 
  --             additional file writing.
  --             (10/2/2023) - Fixed bug where the row size was being 
  --             incorrectly calculated, resulting in an extra character
  --             appearing at the end of some rows. 
  --             Added ability to configure shape type (like column types) 
  --             and to write empty shapefiles.
  --------------------------------------------------------------------------------

  --private
  m_shpfile blob,
  m_shxfile blob,
  m_dbffile blob,
  m_prjfile blob,
  m_nrows integer,
  m_shpShapeType integer,
  m_initializeTable integer,
  m_hasShape integer,
  m_minx number,
  m_miny number,
  m_maxx number,
  m_maxy number,
  m_minz number,
  m_maxz number,
  m_minm number,
  m_maxm number,
  m_hasm integer,
  m_hasz integer,
  m_filelength integer,
  m_columncount integer,
  m_fieldDefs shapefiledbffieldlist,
  m_fields shapefiledbffieldlist,


  -- public functions (use these)

  -- Create a new Shapefile Writer instance.
  constructor function ShapefileWriter return self as result,

  -- Set the configuration for a column. If a column in the input attributes to a susequent call
  -- to 'append' has the name, p_column_name, then use the length, type, and optionally the
  -- number of decimal places of the configuration to store the attribute data in the dbffile
  -- instead of using the defaults. By default, the configuration is a 254 character string.
  -- Calling these procedures after the first append is called has no effect.
  member procedure configureStringColumn(p_column_name in varchar2, p_length in integer),
  member procedure configureNumberColumn(p_column_name in varchar2, p_length in integer, p_decimal_count in integer),
  member procedure configureIntegerColumn(p_column_name in varchar2, p_length in integer),
  member procedure configureDateColumn(p_column_name in varchar2),
  
  -- Set the configuration for the shape column to a predefined geometry type. 
  -- p_shapeType must be one of [None, Point, Line, Polygon]',
  -- p_hasZ must be 1 if the shapefile is to have z values, 0 otherwise.
  -- p_hasM must be 1 if the shapefile is to have z values, 0 otherwise.
  -- If this procedure is not called, then the geometry will be defined by 
  -- the first call to append. Do not call this procedure after append is called.
  member procedure configureShapeColumn(p_shapeType in varchar2, p_hasZ in integer default 0, p_hasM in integer default 0),
  -- add data to the shapefile, using p_shape for the geometry and p_attributes
  -- for the dbase table row. The geometry type and column names are defined
  -- by the inputs provided by the first call to this function.
  member procedure append(p_shape in sdo_geometry, p_attributes in clob),

  -- finalize the shapefile and write it to the input, p_zipfile. 
  -- Within the zipfile, use the name, p_featureclass, as the basename
  -- for the components of the shapefile. If p_closezip is TRUE (default),
  -- then apex_zip.finish will be called for the zipfile, properly closing it.
  -- Otherwise, the zip file remains open and can be used to write additional
  -- files. Caller must ensure than the last call to ShapefileWrite.finish is
  -- TRUE or that apex_zip.finish is otherwise called for the zip file.
  member procedure finish(p_zipfile in out nocopy blob, p_featureclass in varchar2, p_closezip in boolean default TRUE),

  -- Set the well-known text as used in ArcGIS for the shapefile's spatial reference.
  -- This text will be added to the shapefile when 'finish' is called as a '.prj' file.
  member procedure setSpatialReferenceText(p_wkt in varchar2),

  -- Type metadata functions
  static function majorVersion return number,
  static function minorVersion return number,
  static function LastEditedBy return varchar2,
  static function lastModifiedDate return varchar2,
  static function revision return varchar2,

  --private 
  member procedure writeAppendIntegerShp(val in pls_integer, endianess in pls_integer default 2),
  member procedure writeAppendIntegerShpShx(val in pls_integer, endianess in pls_integer default 2),
  member procedure writeAppendDoubleShp(val in binary_double, endianess in pls_integer default 2),
  member procedure writeAppendDoubleShpShx(val in binary_double, endianess in pls_integer default 2),
  member procedure writeIntegerShp(pos in pls_integer, val in pls_integer, endianess in pls_integer default 2),
  member procedure writeIntegerShpShx(pos in pls_integer, val in pls_integer, endianess in pls_integer default 2)
);