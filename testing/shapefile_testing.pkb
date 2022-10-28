create or replace PACKAGE BODY SHAPEFILE_TESTING AS 

  procedure setUp is
  begin
    select file_content into shapefile_testing.testdata from apex_application_static_files where file_name like 'shapefile_util_testdata.zip';
  exception when no_data_found then
    raise_application_error(-20198, 'shapefile_util_testdata.zip not found in apex_application_static_files. This can be remedied by installing the Shapefile Demo apex application.');
  end;
  
  procedure testEmptyShapefile is
    shapef ShapefileReader;

  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'empty', p_srid => 8265);
    ut.expect(shapef.ShapeType).to_equal('Point');
    ut.expect(shapef.GetProgress).to_equal(100);

    ut.expect(shapef.hasnext).to_equal(FALSE);
    ut.expect(sdo_util.to_geojson(shapef.shape)).to_be_null();
    ut.expect(shapef.attributes).to_be_null();
    shapef.MoveNext;
    ut.expect(shapef.hasnext).to_equal(FALSE);
    ut.expect(sdo_util.to_geojson(shapef.shape)).to_be_null();
    ut.expect(shapef.attributes).to_be_null();
  end;
  
  procedure testPointShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'point');
    ut.expect(shapef.ShapeType).to_equal('Point');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-93.0018, -93.0017); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(29.722, 29.724);
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('point 1');        
      elsif i = 2 then
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.881, -92.879); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(29.309, 29.311); 
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('point 2');
      elsif i = 3 then
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.852, -92.850); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.901, 28.903); 
        ut.expect(attributes.get_number('Id')).to_equal(3);
        ut.expect(attributes.get_string('Name')).to_equal('point3');
      elsif i > 3 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testLineShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'line');
    ut.expect(shapef.ShapeType).to_equal('Line');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape, 1)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-90.811, -90.809); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(29.994, 29.996);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-89.271, -89.269); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.159, 29.161);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(20);
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('first line');
      elsif i = 2 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape, 1)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-91.657, -91.655); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(30.995, 30.997);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-91.341, -91.339); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.387, 29.389);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(14);
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('second line');
      elsif i = 3 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape, 1)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-91.647, -91.645); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(30.995, 30.997);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-90.826, -90.824); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.970, 29.972);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(24);
        ut.expect(attributes.get_number('Id')).to_equal(3);
        ut.expect(attributes.get_string('Name')).to_equal('third line');
      elsif i > 3 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testPolygonShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'polygon');
    ut.expect(shapef.ShapeType).to_equal('Polygon');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape, 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.341 - 0.001, -92.341 + .001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.951 - 0.001, 28.951 + 0.001);
        ut.expect(sdo_util.getnumelem(shapef.shape)).to_equal(1);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(6);
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('first polygon');
      elsif i = 2 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape, 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-91.564 - 0.001, -91.564 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.411 - 0.001, 28.411 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-91.564 - 0.001, -91.564 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(28.411 - 0.001, 28.411 + 0.001);
        ut.expect(sdo_util.getnumelem(shapef.shape)).to_equal(1);
        ut.expect(shapef.shape.sdo_elem_info.count).to_equal(3);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(6);
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('second polygon');
      elsif i = 3 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape, 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.166 - 0.001, -92.166 + .001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(30.933 - 0.001, 30.933 + 0.001);
        ut.expect(shapef.shape.sdo_elem_info.count).to_equal(2 * 3);
        ut.expect(sdo_util.getnumelem(shapef.shape)).to_equal(1);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(9);
        
        --hole
        ut.expect(sdo_util.getfirstvertex(sdo_util.extract(shapef.shape, 1, 2)).x).to_be_between(-92.268 - 0.001, -92.268 + .001); 
        ut.expect(sdo_util.getfirstvertex(sdo_util.extract(shapef.shape, 1, 2)).y).to_be_between(30.666 - 0.001, 30.666 + .001); 
        ut.expect(sdo_util.getnumvertices(sdo_util.extract(shapef.shape, 1, 2))).to_equal(4);
        
        ut.expect(attributes.get_number('Id')).to_equal(3);
        ut.expect(attributes.get_string('Name')).to_equal('third polygon');
      elsif i > 3 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testMultiPointShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'multipoint');
    ut.expect(shapef.ShapeType).to_equal('Multipoint');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape, 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-93.186 - 0.001, -93.186 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(31.118 - 0.001, 31.118 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-93.011 - 0.001, -93.011 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(31.370 - 0.001, 31.370 + 0.001);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(4);
        ut.expect(attributes.get_number('Id')).to_equal(0);
        ut.expect(attributes.get_string('Name')).to_equal('first multipoint');
      elsif i = 2 then
        ut.expect(sdo_geom.validate_geometry_with_context(shapef.shape,0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(shapef.shape);
        js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.778 - 0.001, -92.778 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(31.011 - 0.001, 31.011 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-92.462 - 0.001, -92.462 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(31.050 - 0.001, 31.050 + 0.001);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(5);
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('second multipoint');
      elsif i > 2 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testPointZShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'pointmz');
    ut.expect(shapef.ShapeType).to_equal('Point');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-89.669 - 0.001, -89.669 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.839 - 0.001, 28.839 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(0);
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('first mz point');
        ut.expect(attributes.get_string('FieldDate')).to_equal('20020520');
      elsif i = 2 then
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-89.678 - 0.001, -89.678 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.732 - 0.001, 28.732 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(0);
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('second mz point');    
      elsif i > 3 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testLineZShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'linemz');
    ut.expect(shapef.ShapeType).to_equal('Line');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        --ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.005)).to_equal('TRUE');
        --wkt := sdo_util.to_wktgeometry(sdo_lrs.convert_to_std_geom(shapef.shape));
        --js := sdo_util.to_geojson(sdo_lrs.convert_to_std_geom(shapef.shape));
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-90.145 - 0.001, -90.145 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(30.957 - 0.001, 30.957 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(5.0);
        
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-90.635 - 0.001, -90.635 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(30.729 - 0.001, 30.729 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_equal(-1.0);
        
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(7);
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('first mz line');
      elsif i = 2 then
        --ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.005)).to_equal('TRUE');
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-90.533 - 0.001, -90.533 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(30.408 - 0.001, 30.408 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(1.0);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).w).to_equal(4.0);
        
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-90.014 - 0.001, -90.014 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(30.287 - 0.001, 30.287 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_equal(3.0);
        ut.expect(sdo_util.getlastvertex(shapef.shape).w).to_be_between(6.6- 0.00001, 6.6 + 0.00001);
        
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(3);
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('second mz line');
      elsif i > 3 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testPolygonZShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'polygonmz');
    ut.expect(shapef.ShapeType).to_equal('Polygon');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.005, 'FALSE', 'TRUE')).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(sdo_cs.make_2d(shapef.shape));
        js := sdo_util.to_geojson(sdo_cs.make_2d(shapef.shape));
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-93.808 - 0.001, -93.808 + .001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(29.359 - 0.001, 29.359 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(66.0);
        ut.expect(sdo_util.getvertices(shapef.shape)(sdo_util.getnumvertices(shapef.shape)-1).x).to_be_between(-93.274- 0.001, -93.274 + .001); 
        ut.expect(sdo_util.getvertices(shapef.shape)(sdo_util.getnumvertices(shapef.shape)-1).y).to_be_between(29.388- 0.001, 29.388 + .001); 
        ut.expect(sdo_util.getvertices(shapef.shape)(sdo_util.getnumvertices(shapef.shape)-1).z).to_equal(0.0); 
        ut.expect(sdo_util.getvertices(shapef.shape)(2).x).to_be_between(-93.910 - 0.001, -93.910 + .001); 
        ut.expect(sdo_util.getvertices(shapef.shape)(2).y).to_be_between(28.897 - 0.001, 28.897 + 0.001); 
        ut.expect(sdo_util.getvertices(shapef.shape)(2).z).to_equal(1.0); 
        
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-93.808 - 0.001, -93.808 + .001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.359 - 0.001, 29.359 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_equal(66.0);
        
        ut.expect(sdo_util.getnumelem(shapef.shape)).to_equal(1);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(6);
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('first mz polygon');
      
      elsif i > 1 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testMultiPointZShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'multipointmz');
    ut.expect(shapef.ShapeType).to_equal('Multipoint');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        --ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(sdo_lrs.convert_to_std_geom(shapef.shape));
        js := sdo_util.to_geojson(sdo_lrs.convert_to_std_geom(shapef.shape));
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-90.393 - 0.001, -90.393 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(29.266 - 0.001, 29.266 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(5.0);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).w).to_equal(0.0);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-90.174 - 0.001, -90.174 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.189 - 0.001, 29.189+ 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_equal(7.0);
        ut.expect(sdo_util.getlastvertex(shapef.shape).w).to_equal(3.0);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(4);
        ut.expect(attributes.get_number('Id')).to_equal(0);
        ut.expect(attributes.get_string('Name')).to_equal('first mz multipoint');
      elsif i > 1 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testPointMShapefileReader is
   shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'pointm');
    ut.expect(shapef.ShapeType).to_equal('Point');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-90.835 - 0.001, -90.835 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.377 - 0.001, 28.377 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).w).to_be_null();
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('m point 1');
      elsif i = 2 then
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-90.684 - 0.001, -90.684 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.397 - 0.001, 28.397+ 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_be_null();
        ut.expect(sdo_util.getfirstvertex(shapef.shape).w).to_be_null();
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('m point 2');    
      elsif i = 3 then
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-90.840 - 0.001, -90.840 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.489 - 0.001, 28.489 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_be_null();
        ut.expect(sdo_util.getfirstvertex(shapef.shape).w).to_be_null(); -- to_be_between(55 - 0.001, 55 + 0.001);
        ut.expect(attributes.get_number('Id')).to_equal(3);
        ut.expect(attributes.get_string('Name')).to_equal('m point 3');
      elsif i > 3 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testLineMShapefileReader is
  shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'linem');
    ut.expect(shapef.ShapeType).to_equal('Line');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.05)).to_equal('TRUE');
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);

        
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.943 - 0.001, -92.943 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(30.826 - 0.001, 30.826 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_be_null();
        
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-92.011 - 0.001, -92.011 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.820 - 0.001, 29.820 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_be_null();
        
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('first m line');
      elsif i = 2 then
        ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.05)).to_equal('TRUE');
        --wkt := sdo_util.to_wktgeometry(shapef.shape);
        --js := sdo_util.to_geojson(shapef.shape);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.783 - 0.001, -92.783 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(30.870 - 0.001, 30.870 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(0.0);
        
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-92.040 - 0.001, -92.040 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(30.034 - 0.001, 30.034 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_equal(3.0);
        
        ut.expect(attributes.get_number('Id')).to_equal(2);
        ut.expect(attributes.get_string('Name')).to_equal('second line m');
      elsif i > 3 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testPolygonMShapefileReader is
  shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'polygonm');
    ut.expect(shapef.ShapeType).to_equal('Polygon');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(sdo_lrs.convert_to_std_geom(shapef.shape));
        js := sdo_util.to_geojson(sdo_lrs.convert_to_std_geom(shapef.shape));
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-89.911 - 0.001, -89.911 + .001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(28.377 - 0.001, 28.377 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(.0);
         
        
        
        
        ut.expect(sdo_util.getvertices(shapef.shape)(sdo_util.getnumvertices(shapef.shape)-1).x).to_be_between(-89.484- 0.001, -89.484 + .001); 
        ut.expect(sdo_util.getvertices(shapef.shape)(sdo_util.getnumvertices(shapef.shape)-1).y).to_be_between(28.577 - 0.001, 28.577 + .001); 
        ut.expect(sdo_util.getvertices(shapef.shape)(sdo_util.getnumvertices(shapef.shape)-1).z).to_equal(2.0);
        
        
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-89.911 - 0.001, -89.911 + .001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(28.377 - 0.001, 28.377 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_equal(0);
        
        ut.expect(sdo_util.getnumelem(shapef.shape)).to_equal(1);
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(6);
        ut.expect(attributes.get_number('Id')).to_equal(0);
        ut.expect(attributes.get_string('Name')).to_equal('first m polygon');
      
      elsif i > 1 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testMultiPointMShapefileReader is
    shapef ShapefileReader;
    geom sdo_geometry;
    attributes json_object_t;
    i pls_integer;
    wkt clob;
    js clob;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'multipointm');
    ut.expect(shapef.ShapeType).to_equal('Multipoint');
    ut.expect(shapef.GetProgress).to_equal(0);
    i := 1;
    while shapef.hasnext loop
      shapef.movenext;
      
      geom := shapef.shape;
      attributes := json_object_t(shapef.attributes);
      if i = 1 then
        --ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(sdo_lrs.convert_to_std_geom((shapef.shape)));
        js := sdo_util.to_geojson(sdo_lrs.convert_to_std_geom(shapef.shape));
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-92.020 - 0.001, -92.020 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(29.398 - 0.001, 29.398 + 0.001);
        
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_equal(0.0);
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-91.792 - 0.001, -91.792 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.160 - 0.001, 29.160 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_equal(9.0);
        
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(4);
        ut.expect(attributes.get_number('Id')).to_equal(0);
        ut.expect(attributes.get_string('Name')).to_equal('first m multipoint');
      elsif i = 2 then
        --ut.expect(sdo_geom.validate_geometry_with_context(sdo_lrs.convert_to_std_geom(shapef.shape), 0.001)).to_equal('TRUE');
        wkt := sdo_util.to_wktgeometry(sdo_lrs.convert_to_std_geom(shapef.shape));
        js := sdo_util.to_geojson(sdo_lrs.convert_to_std_geom(shapef.shape));
        ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_be_between(-91.291 - 0.001, -91.291 + 0.001); 
        ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_be_between(29.024 - 0.001, 29.024 + 0.001);
        ut.expect(sdo_util.getfirstvertex(shapef.shape).z).to_be_null();
        ut.expect(sdo_util.getfirstvertex(shapef.shape).w).to_be_null();
        ut.expect(sdo_util.getlastvertex(shapef.shape).x).to_be_between(-91.291 - 0.001, -91.291 + 0.001); 
        ut.expect(sdo_util.getlastvertex(shapef.shape).y).to_be_between(29.024 - 0.001, 29.024 + 0.001);
        ut.expect(sdo_util.getlastvertex(shapef.shape).z).to_be_null();
        ut.expect(sdo_util.getlastvertex(shapef.shape).w).to_be_null();
        ut.expect(sdo_util.getnumvertices(shapef.shape)).to_equal(1);
        ut.expect(attributes.get_number('Id')).to_equal(1);
        ut.expect(attributes.get_string('Name')).to_equal('second m multipoint');
      elsif i > 2 then
        ut.fail('Extra features found');
      end if;
      i := i + 1;
    end loop;
    ut.expect(shapef.GetProgress).to_equal(100);
  end;
  
  procedure testNullShapefileReader is 
    shapef ShapefileReader;
  begin
    shapef := ShapefileReader(p_shapefilezip => null);
    ut.fail('No exception for null input shapfile zip');
  exception when others then
    if SQLCODE = -20481 then
      ut.expect(1).to_equal(1);
    else
      raise;
    end if;
  end;
  
  procedure testNonexistentShapefile is
    shapef ShapefileReader;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'morning_star_ranch');
    ut.fail('No exception for null input shapfile zip');
  exception when others then
    if SQLCODE = -20480 then
      dbms_output.put_line(chr(9) || SQLERRM);
      ut.expect(1).to_equal(1);
    else
      raise;
    end if;
  end;
  
  procedure testInvalidShapefile is
    shapef ShapefileReader;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'fake');
    ut.fail('No exception for invalid input shapfile zip');
  exception when others then
    if SQLCODE = -20499 then
      dbms_output.put_line(chr(9) || SQLERRM);
      ut.expect(1).to_equal(1);
    else
      raise;
    end if;
  end;
  
  procedure testMissingShapefileComponent is
    shapef ShapefileReader;
  begin
    shapef := ShapefileReader(p_shapefilezip => testdata, p_featureclass => 'missing');
    ut.fail('No exception for invalid input shapfile zip');
  exception when others then
    if SQLCODE = -20481 then
      dbms_output.put_line(chr(9) || SQLERRM);
      ut.expect(1).to_equal(1);
    else
      raise;
    end if;
  end;

  procedure testPointShapefileWriter is
    shapew ShapefileWriter;
    shapef ShapefileReader;
    outb blob;
  begin
    dbms_lob.createtemporary(outb, true);
    shapew := ShapefileWriter();
    shapew.configureIntegerColumn('Num1', 10);
    shapew.configureDateColumn('Date1');
    shapew.configureStringColumn('String1', 3);
    shapew.append(sdo_geometry('Point(-91 33)'), json_object('Id' value 1, 'Name' value 'Mark Middleton', 'Num1' value 10, 'Date1' value to_date('05/07/2022', 'MM/DD/YYYY'), 'String1' value 'abc'));
    shapew.append(sdo_geometry('Point(-92 34)'), json_object('Id' value 21, 'Name' value 'Christopher Sign', 'Num1' value 25, 'Date1' value to_date('06/12/2021', 'MM/DD/YYYY'), 'String1' value 'def'));
    shapew.append(sdo_geometry('Point(-91.5 33.5)'), json_object('Id' value 21, 'Name' value 'Michael Hastings', 'Num1' value 55, 'Date1' value to_date('06/18/2013', 'MM/DD/YYYY'), 'String1' value 'def'));
    shapew.finish(outb, 'a.out.zip');
    shapef := ShapefileReader(outb, 8265);
    shapef.MoveNext;
    ut.expect(json_object_t(shapef.Attributes).get_number('Id')).to_equal(1);
    ut.expect(json_object_t(shapef.Attributes).get_number('Num1')).to_equal(10);
    ut.expect(json_object_t(shapef.Attributes).get_string('Name')).to_equal('Mark Middleton');
    ut.expect(json_object_t(shapef.Attributes).get_string('Date1')).to_equal('20220507');
    ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_equal(-91);
    ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_equal(33);
    shapef.MoveNext;
    ut.expect(json_object_t(shapef.Attributes).get_number('Id')).to_equal(21);
    ut.expect(json_object_t(shapef.Attributes).get_number('Num1')).to_equal(25);
    ut.expect(json_object_t(shapef.Attributes).get_string('Name')).to_equal('Christopher Sign');
    ut.expect(json_object_t(shapef.Attributes).get_string('Date1')).to_equal('20210612');
    ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_equal(-92);
    ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_equal(34);
    shapef.MoveNext;
    ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_equal(-91.5);
    ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_equal(33.5);
  end;
  
procedure testLineShapefileWriter is
    shapew ShapefileWriter;
    shapef ShapefileReader;
    outb blob;
  begin
    dbms_lob.createtemporary(outb, true);
    shapew := ShapefileWriter();
    shapew.configureIntegerColumn('Num1', 10);
    shapew.configureDateColumn('Date1');
    shapew.configureStringColumn('String1', 3);
    shapew.append(sdo_geometry('LineString(-91 33, -92 34)'), json_object('Id' value 1, 'Name' value 'Mark Middleton', 'Num1' value 10, 'Date1' value to_date('05/07/2022', 'MM/DD/YYYY'), 'String1' value 'abc'));
    shapew.append(sdo_geometry('LineString(-92 33, -91 34)'), json_object('Id' value 21, 'Name' value 'Christopher Sign', 'Num1' value 25, 'Date1' value to_date('06/12/2021', 'MM/DD/YYYY'), 'String1' value 'def'));
    shapew.finish(outb, 'a.out.zip');
    shapef := ShapefileReader(outb, 8265);
    shapef.MoveNext;
    ut.expect(json_object_t(shapef.Attributes).get_number('Id')).to_equal(1);
    ut.expect(json_object_t(shapef.Attributes).get_number('Num1')).to_equal(10);
    ut.expect(json_object_t(shapef.Attributes).get_string('Name')).to_equal('Mark Middleton');
    ut.expect(json_object_t(shapef.Attributes).get_string('Date1')).to_equal('20220507');
    --ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_equal(-91);
    --ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_equal(33);
    shapef.MoveNext;
    ut.expect(json_object_t(shapef.Attributes).get_number('Id')).to_equal(21);
    ut.expect(json_object_t(shapef.Attributes).get_number('Num1')).to_equal(25);
    ut.expect(json_object_t(shapef.Attributes).get_string('Name')).to_equal('Christopher Sign');
    ut.expect(json_object_t(shapef.Attributes).get_string('Date1')).to_equal('20210612');
    --ut.expect(sdo_util.getfirstvertex(shapef.shape).x).to_equal(-92);
    --ut.expect(sdo_util.getfirstvertex(shapef.shape).y).to_equal(34);
  end;
  
END SHAPEFILE_TESTING;