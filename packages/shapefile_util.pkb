create or replace PACKAGE BODY "SHAPEFILE_UTIL" is
  function ShapefileJSON(p_shapefilezip in blob, p_srid in integer default null, p_featureclass in varchar2 default null) return clob is
    rt clob;
    l_geom sdo_geometry;
    shapef ShapefileReader;
    i pls_integer;
  begin
    shapef := ShapefileReader(p_shapefilezip, p_srid, p_featureclass);
    rt:= '{"type": "FeatureCollection", "features": [';
    
    i := 1;
    while shapef.HasNext loop
      shapef.MoveNext;
      
      if i > 1 then
        rt := rt || ', ';
      end if;
      
      -- convert geometry to geographic coordinate system, required by geojson.
      if shapef.HasZ = 1 and shapef.HasM = 1 then
        l_geom := sdo_cs.make_3d(shapef.shape, 8265);
      elsif shapef.hasZ = 0 and shapef.hasM = 1 then
        l_geom := sdo_cs.make_2d(shapef.shape, 8265);
      else
        l_geom := shapef.shape;
      end if;
      rt := rt || '{"type": "Feature", "geometry": '; 
      dbms_lob.append(rt, sdo_util.to_geojson(l_geom));
      rt := rt || ', "properties":';
      dbms_lob.append(rt, shapef.attributes);
      rt := rt || '}';
      
      i := i + 1;
    end loop;
    return rt;
  end;
  
  function ShapefileTable(p_shapefilezip in blob) return shapefile_tab is
  begin
    return ShapefileTable(p_shapefilezip, null, null);
  end;
  function ShapefileTable(p_shapefilezip in blob, p_srid in integer) return shapefile_tab is
  begin
    return ShapefileTable(p_shapefilezip, p_srid, null);
  end;
  
  function ShapefileTable(p_shapefilezip in blob, p_featureclass in varchar2) return shapefile_tab is
  begin
    return ShapefileTable(p_shapefilezip, null, p_featureclass);
  end;
  
  function ShapefileTable(p_shapefilezip in blob, p_srid in integer, p_featureclass in varchar2, p_vertical_datum in varchar2 default 'NAVD88', p_vertical_units in varchar2 default 'FEET') return shapefile_tab is
    shapef ShapefileReader;
    rt shapefile_tab;
  begin
    shapef := ShapefileReader(p_shapefilezip, p_srid, p_featureclass, p_vertical_datum, p_vertical_units);
    rt := shapefile_tab();
    while shapef.HasNext loop
      shapef.MoveNext;
      rt.extend;
      rt(rt.last) := shapefile_t(shapef.shape, shapef.attributes);
    end loop;
    return rt;
  end;
  
  function ShapefileTablePipe(p_shapefile in ShapefileReader) return shapefile_tab pipelined is 
    shapef ShapefileReader;
  begin
    shapef := p_shapefile;
    while shapef.HasNext loop
      shapef.MoveNext;
      pipe row(shapefile_t(shapef.shape, shapef.attributes));
    end loop;
    return;
  end;
  
  function ListFeatureClasses(p_shapefilezip in blob, p_shapetype in varchar2 default null, p_delimiter in varchar2 default ',') return varchar2  is
    l_files apex_zip.t_files;
    i pls_integer;
    rt varchar2(32767);
    n pls_integer;
    l_shapef ShapefileReader;
  begin
    l_files := apex_zip.get_files(p_zipped_blob => p_shapefilezip);
    n := 0;
    for i in 1..l_files.count loop
      if regexp_instr(lower(l_files(i)), '\.shp$') > 0 then
        if not p_shapetype is null then
          l_shapef := ShapefileReader(p_shapefilezip, 4326, substr(l_files(i), 1, length(l_files(i)) - 4));
          if not l_shapef.ShapeType = p_shapetype then
            continue;
          end if;
        end if;
        if n > 0 then
          rt := rt || p_delimiter;
        end if;
        rt := rt || substr(l_files(i), 1, length(l_files(i)) - 4);
        n := n + 1;
      end if;
    end loop;
    return rt;
  end;
  
  function ListFields(p_shapefilezip in blob, p_featureclass in varchar2) return ShapefileDBFFieldList is
    l_shapef ShapefileReader;
  begin
    l_shapef := ShapefileReader(p_shapefilezip, 4326, p_featureclass);
    return l_shapef.Fields;
  end;
  
  function GetFeatureCount(p_shapefilezip in blob, p_featureclass in varchar2 default null) return integer is
    l_shapef ShapefileReader;
  begin
    l_shapef := ShapefileReader(p_shapefilezip, 4326, p_featureclass);
    return l_shapef.Count;
  end;
  
  function GetSpatialReferenceId(p_shapefilezip in blob, p_featureclass in varchar2 default null) return integer is
    l_shapef ShapefileReader;
  begin
    l_shapef := ShapefileReader(p_shapefilezip, 4326, p_featureclass);
    return l_shapef.SRID;
  end;
  
  function GenerateJSONQuery(p_shapefilezip in blob, p_srid in integer default null, p_featureclass in varchar2 default null, p_blobname in varchar2) return varchar2 is
    rt varchar2(32767);
    shapef ShapefileReader;
    i pls_integer;
    ftype varchar2(4000);
  begin
    shapef := ShapefileReader(p_shapefilezip, p_srid, p_featureclass);
    rt := 'json_table(' || p_blobname || ', ''$'' COLUMNS(';
    shapef := ShapefileReader(p_shapefilezip, p_srid, p_featureclass);
    for i in 1..shapef.Fields.count loop
      if i > 1 then
        rt := rt || ', ';
      end if;
      if shapef.Fields(i).fieldType in ('C', 'L', 'D') then
        ftype := 'VARCHAR2(' || (shapef.Fields(i).fieldLength) || ')';
      else 
        ftype := 'NUMBER';
      end if;
      rt := rt || shapef.Fields(i).name || ' ' || ftype || ' path ''$.' || shapef.Fields(i).name || '''';
    end loop;
    rt := rt || '))';
    return rt;
  end;
  
  function WriteShapefile(p_query in varchar2, p_output_filename in varchar2) return blob is
    rt blob;
    l_cursor integer;
    l_shape sdo_geometry;
    n integer;
    l_attr clob;
    rs sys_refcursor;
    l_feat shapefile_t;
    
    w ShapefileWriter;
  begin
    w := ShapefileWriter();
    l_cursor := dbms_sql.open_cursor();
    dbms_sql.parse(l_cursor, p_query, dbms_sql.native);
    dbms_sql.define_column(l_cursor, 1, l_shape);
    dbms_sql.define_column(l_cursor, 2, l_attr);
    n := dbms_sql.execute(l_cursor);
    loop
      if dbms_sql.fetch_rows(l_cursor) >0 then
        dbms_sql.column_value(l_cursor, 1, l_shape);
        dbms_sql.column_value(l_cursor, 2, l_attr);
        w.append(l_shape, l_attr);
      else
        exit;
      end if;
    end loop;
   
    dbms_sql.close_cursor(l_cursor);
    w.finish(rt, p_output_filename);
    return rt;
  end;
  
  function majorVersion return number is
  begin
    return m_majorVersion;
  end;
  function minorVersion return number is
  begin
    return m_minorVersion;
  end;
  function lastEditedBy return varchar2 is
  begin
    return '$Author: b2imimcf $';
  end;
  function lastModifiedDate return varchar2 is
  begin
    return '$Date: 2024-10-03 14:31:37 -0500 (Thu, 03 Oct 2024) $';
  end;
  function revision return varchar2 is
  begin
    return '$Revision: 19582 $';
  end;
end;
