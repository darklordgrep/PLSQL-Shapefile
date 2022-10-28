create or replace type ShapefileDBFField FORCE as object (
  name varchar2(12),
  fieldType varchar2(1),
  address integer,
  fieldLength integer,
  decimalCount integer,
  constructor function ShapefileDBFField return self as result
);
/

create or replace type  body ShapefileDBFField  is
  constructor function ShapefileDBFField return self as result is
  begin
    return;
  end;
end;
/

create or replace type ShapefileDBFFieldList FORCE as table of ShapefileDBFField;
/

create or replace type shapefile_t FORCE as object(
  shape sdo_geometry,
  attributes clob
);
/

create or replace type shapefile_tab is table of shapefile_t;
/