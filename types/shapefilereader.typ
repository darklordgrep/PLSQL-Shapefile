create or replace type ShapefileReader as object ( 
  --------------------------------------------------------------------------------
  -- Module   : $HeadURL: svn://gis.mvn.usace.army.mil/sandp/DatabaseScripts/ShapefileComponent/trunk/types/shapefilereader.typ $
  -- Author   : grep
  -- Date     : $Date: 2023-05-19 10:38:43 -0500 (Fri, 19 May 2023) $
  -- Revision : $Revision: 18187 $
  -- Requires : Tables oracle_srid_xref, oracle_3d_srid_xref and types
  --            ShapefileDBFFieldList, ShapefileDBFField
  -- Usage    : ShapefileReader is a cursor that takes as input a zipfile containing 
  --            one or more shapefiles and iterates over 
  --            the features in that dataset like a cursor.
  --            The HasNext function returns true so long at there are records 
  --            left to read and the MoveNext procedure moves the the next record. 
  --            The Shape and Attributes member variables contain an sdo_geometry 
  --            and javascript associate array respectively of the current record.
  --            
  --            Constructors include a p_featureclass parameter to pick 
  --            a specific dataset from the zip if multiple shapefiles are included. 
  -- 
  --            Typical use would be as follows:
  -- 
  --               shapef := shapefilereader(p_shapefilezip);
  --               while shapef.HasNext loop
  --                 shapef.MoveNext;
  --                 l_sdo_shape := shapef.shape;
  --                 l_clob_attr := shapef.attributes;
  --               end loop;
  --
  --            Notably, the Attributes member variable can be (and is intended 
  --            to be) parsed by JSON_TABLE and similar functions.
  --
  -- Notes     : Version 1.0 - Initial release.
  --             Point MZ and Point M types lose the m values during read.
  --             If the shapefile contains m values, but not z values, 
  --             then calls to sdo_util.getvertices and similar functions will
  --             return the m value in the z column, otherwise it will be the w
  --             column.
  --             Dates will be read as strings, apparently in YYYYMMDD format.
  --             
  --             Version 1.1 - Added support for reading dbase (dbf files with no
  --             associated shp file). These are treated as shapefiles with
  --             no geometry.
  --------------------------------------------------------------------------------
  -- public members (use these)
  -- sdo_geometry of the current record. This value is null prior to MoveNext being call
  -- and also after MoveNext is called after the last record is read. It is
  -- also always null when reading datasets with no geometry.
  -- This attribute should only be read, not modified.
  Shape sdo_geometry,
  -- javascript associated array (JSON) of attribute values for the current record.
  -- This value is null prior to MoveNext being call and also after MoveNext 
  -- is called after the last record is read.
  -- This attribute should only be read, not modified.
  Attributes clob,
  -- Not implemented
  Metadata xmltype,
  -- Oracle Coordinate Reference System ID for the shapefile.
  -- This attribute should only be read, not modified.
  SRID number,
  -- 1 if the shapefile has non-null M values, 0 otherwise.
  -- This attribute should only be read, not modified.
  HasM integer,
  -- 1 if the shapefile has non-null Z alues, 0 otherwise.
  -- This attribute should only be read, not modified.
  HasZ integer,
  -- Array of Field Definitions. This attribute should only be read, not modified.
  Fields ShapefileDBFFieldList,
  -- Return one of the following strings: [Point, Line, Polygon, Multipoint], corresponding
  -- to the shape type of the shapefile. This attribute should only be read, not modified.
  ShapeType varchar2(20),
  -- private members (don't use these)
  m_dbf blob,
  m_dbf_pos number,
  m_dbf_nRecords number,
  m_dbf_nHeaderBytes number,
  m_dbf_nRecordBytes number,
  m_dbf_nTotalBytes number,
  m_dbf_nFields number,
  m_shp blob,
  m_shp_pos number,
  m_shp_fileLength number,
  m_shp_shapeType number,
  m_shp_wordsRead number,
  m_ordinates sdo_ordinate_array,
  m_shp_gtype number,
  m_shp_etype number,
  m_single_part number,
  -- public members (constructors)
  -- Given an input zipfile, p_shapefilezip, containing a single shapefile, 
  -- create a new ShapefileReader instance using the coordinate system reference provided by the included prj file.
  -- If there are more than one shapefiles in the zip, raise exception.
  -- If the prj is missing or invalid, raise exception.
  -- If the shapefile has z values, assume the vertical datum is NAVD88 and the vertical units are FEET.
  constructor function ShapefileReader(p_shapefilezip in blob) return self as result,
  -- Given an input zipfile, p_shapefilezip, containing a single shapefile, 
  -- Create a new ShapefileReader instance using the coordinate system reference associated with SRID in p_srid argument,
  -- ignoring any included prj file. SRID lookup uses the ORACLE_SRID_XREF table.
  -- If there are more than one shapefiles in the zip, raise exception.
  constructor function ShapefileReader(p_shapefilezip in blob, p_srid in integer) return self as result,
  -- Given an input zipfile, p_shapefilezip, that may contain multiple shapefiles, 
  -- Create a new ShapefileReader instance using the shapefile with in the input featureclass name, p_featureclass 
  -- and the coordinate system reference provided by the included prj file.
  -- The featureclass is the shapefile filename with the full zip path, but without the extention.
  -- If the prj is missing or invalid, raise exception.
  -- If the shapefile has z values, assume the vertical datum is NAVD88 and the vertical units are FEET.
  constructor function ShapefileReader(p_shapefilezip in blob, p_featureclass in varchar2) return self as result,
  -- Given an input zipfile, p_shapefilezip, that may contain multiple shapefiles, 
  -- Create a new ShapefileReader instance using the shapefile with in the input featureclass name, p_featureclass.
  -- The featureclass is the shapefile filename with the full zip path, but without the extention.
  -- If p_featureclass is null, assume there is only one featureclass and if there are more than one shapefiles in the zip, raise exception.
  -- If p_srid is null, use the coordinate system reference provided by the included prj file and if the prj is missing or invalid, raise exception.
  -- If the shapefile has z values and no p_srid is specified, then lookup the coordinate reference system in oracle_3d_srid_xref table , using the
  -- p_vertical_datum and p_vertical_units arguments.
  -- By default lines and polygons are read as multipart (with an sdo gtype of XX06 or XX07). To force them into single part (with an sdo
  -- gtype of XX02 or XX03), set p_force_single_part to true. Reading a multipart geometry from the shape will result in an error if 
  -- p_force_single_part is set to true.
  constructor function ShapefileReader(p_shapefilezip in blob, p_srid in integer, p_featureclass in varchar2, p_vertical_datum in varchar2 default 'NAVD88', p_vertical_units in varchar2 default 'FEET', p_force_single_part in boolean default false) return self as result,
  -- Return true if the instance has any records left to read, false otherwise.
  member function HasNext return boolean,
  -- Move the next record in the shapefile, udpating the member variables to Shapefile and Attribute to that of the record.
  member procedure MoveNext,
  -- Return an integer between 0 and 100 inclusive, representing the percentage of the shapefile that has been read (by calls to MoveNext).
  -- This percentage is based on number of bytes read out of total bytes, not number of records read out of total records.
  member function GetProgress return integer,
  -- Type metadata functions
  static function majorVersion return number,
  static function minorVersion return number,
  static function LastEditedBy return varchar2,
  static function lastModifiedDate return varchar2,
  static function revision return varchar2,
  -- private members (stay away, I can't encapsulate.)
  static function readString(b in blob, pos in out pls_integer, len in pls_integer) return varchar2,
  static function readInteger(b in blob, pos in out pls_integer, endianess in pls_integer) return pls_integer,
  static function readShortInteger(b in blob, pos in out pls_integer, endianess in pls_integer) return pls_integer,
  static function readByteInteger(b in blob, pos in out pls_integer, endianess in pls_integer) return pls_integer,
  static function readDouble(b in blob, pos in out pls_integer, endianess in pls_integer) return number,
  member function readPoint(pos in out pls_integer, dim in pls_integer) return sdo_geometry,
  member function readPoly(pos in out pls_integer, dim in pls_integer) return sdo_geometry,
  member function readMultiPoint(pos in out pls_integer, dim in pls_integer) return sdo_geometry,
  member procedure makePolygonHoles(p_geom in out sdo_geometry, dim in pls_integer)
);