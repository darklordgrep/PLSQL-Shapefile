--------------------------------------------------------
--  File created - Sunday-August-14-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table ORACLE_3D_SRID_XREF
--------------------------------------------------------

  CREATE TABLE "ORACLE_3D_SRID_XREF" 
   (	"ORACLE_3D_SRID_XREF_ID" NUMBER(38,0), 
	"ORACLE_SRID_XREF_ID" NUMBER(38,0), 
	"VERTICAL_DATUM" VARCHAR2(12), 
	"EPOCH" VARCHAR2(12), 
	"VERTICAL_UNITS" VARCHAR2(8), 
	"SRID" NUMBER(10,0)
   ) ;

   COMMENT ON COLUMN "ORACLE_3D_SRID_XREF"."ORACLE_3D_SRID_XREF_ID" IS 'The unique identifier of an ORACLE_3D_SRID_XREF record';
   COMMENT ON COLUMN "ORACLE_3D_SRID_XREF"."ORACLE_SRID_XREF_ID" IS 'The foreign key link to the 2D coordsys record that defines the 2D component of the 3D SRID';
   COMMENT ON COLUMN "ORACLE_3D_SRID_XREF"."VERTICAL_DATUM" IS 'Vertical datum for earth measurements';
   COMMENT ON COLUMN "ORACLE_3D_SRID_XREF"."EPOCH" IS 'Epoch within a vertical datum';
   COMMENT ON COLUMN "ORACLE_3D_SRID_XREF"."VERTICAL_UNITS" IS 'Units of measurement for vertical distance above sea level';
   COMMENT ON COLUMN "ORACLE_3D_SRID_XREF"."SRID" IS 'Link ID for an Oracle Spatial SDO_COOR_REF_SYSTEM record for a 3D geographic or projected coordinate reference system';
   COMMENT ON TABLE "ORACLE_3D_SRID_XREF"  IS 'A reference table that stores defining information about 3D coordinate reference systems that have been added to Oracle Spatial';
REM INSERTING into ORACLE_3D_SRID_XREF
SET DEFINE OFF;
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (3,2,'NAVD88',null,'METERS',5498);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (4,3,'NAVD88',null,'METERS',5498);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (5,2,'NAVD88',null,'FEET',775498);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (6,3,'NAVD88',null,'FEET',775498);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (7,4,'NAVD88',null,'METERS',5499);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (8,4,'NAVD88',null,'FEET',775499);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (9,9,'NAVD88',null,'METERS',663452);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (10,11,'NAVD88',null,'METERS',663452);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (11,9,'NAVD88',null,'FEET',773452);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (12,11,'NAVD88',null,'FEET',773452);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (13,13,'NAVD88',null,'METERS',663457);
Insert into ORACLE_3D_SRID_XREF (ORACLE_3D_SRID_XREF_ID,ORACLE_SRID_XREF_ID,VERTICAL_DATUM,EPOCH,VERTICAL_UNITS,SRID) values (14,13,'NAVD88',null,'FEET',773457);
--------------------------------------------------------
--  DDL for Index SRID3X_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "SRID3X_PK" ON "ORACLE_3D_SRID_XREF" ("ORACLE_3D_SRID_XREF_ID") 
  ;
--------------------------------------------------------
--  DDL for Index SRID3X_SPAT_REF_UK
--------------------------------------------------------

  CREATE UNIQUE INDEX "SRID3X_SPAT_REF_UK" ON "ORACLE_3D_SRID_XREF" ("ORACLE_SRID_XREF_ID", "VERTICAL_DATUM", "EPOCH", "VERTICAL_UNITS") 
  ;
--------------------------------------------------------
--  DDL for Index SRID3X_SRIDX_FK_I
--------------------------------------------------------

  CREATE INDEX "SRID3X_SRIDX_FK_I" ON "ORACLE_3D_SRID_XREF" ("ORACLE_SRID_XREF_ID") 
  ;
--------------------------------------------------------
--  DDL for Trigger ORACLE_3D_SRID_XREF_BIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ORACLE_3D_SRID_XREF_BIR" 
 BEFORE INSERT ON ORACLE_3D_SRID_XREF for each row
 begin
 IF :new.ORACLE_3D_SRID_XREF_ID IS NULL THEN
     SELECT ORACLE_3D_SRID_XREF_SEQ.nextval into :new.ORACLE_3D_SRID_XREF_ID from dual;
 END IF;
 IF :new.VERTICAL_DATUM IS NOT NULL THEN
   check_value_against_domain(:new.VERTICAL_DATUM, 'VERTICAL_DATUMS');
 END IF;
 IF :new.EPOCH IS NOT NULL THEN
   check_value_against_domain(:new.EPOCH, 'EPOCHS');
 END IF;
 IF :new.VERTICAL_UNITS IS NOT NULL THEN
   check_value_against_domain(:new.VERTICAL_UNITS, 'UNITS');
 END IF;
 end;
/
ALTER TRIGGER "ORACLE_3D_SRID_XREF_BIR" ENABLE;
--------------------------------------------------------
--  DDL for Trigger ORACLE_3D_SRID_XREF_BUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ORACLE_3D_SRID_XREF_BUR" 
 BEFORE UPDATE ON ORACLE_3D_SRID_XREF for each row
 begin
 IF :new.VERTICAL_DATUM IS NOT NULL THEN
   check_value_against_domain(:new.VERTICAL_DATUM, 'VERTICAL_DATUMS');
 END IF;
 IF :new.EPOCH IS NOT NULL THEN
   check_value_against_domain(:new.EPOCH, 'EPOCHS');
 END IF;
 IF :new.VERTICAL_UNITS IS NOT NULL THEN
   check_value_against_domain(:new.VERTICAL_UNITS, 'UNITS');
 END IF;
 end;
/
ALTER TRIGGER "ORACLE_3D_SRID_XREF_BUR" ENABLE;
--------------------------------------------------------
--  Constraints for Table ORACLE_3D_SRID_XREF
--------------------------------------------------------

  ALTER TABLE "ORACLE_3D_SRID_XREF" MODIFY ("ORACLE_3D_SRID_XREF_ID" NOT NULL ENABLE);
  ALTER TABLE "ORACLE_3D_SRID_XREF" MODIFY ("ORACLE_SRID_XREF_ID" NOT NULL ENABLE);
  ALTER TABLE "ORACLE_3D_SRID_XREF" MODIFY ("VERTICAL_DATUM" NOT NULL ENABLE);
  ALTER TABLE "ORACLE_3D_SRID_XREF" MODIFY ("VERTICAL_UNITS" NOT NULL ENABLE);
  ALTER TABLE "ORACLE_3D_SRID_XREF" MODIFY ("SRID" NOT NULL ENABLE);
  ALTER TABLE "ORACLE_3D_SRID_XREF" ADD CONSTRAINT "SRID3X_PK" PRIMARY KEY ("ORACLE_3D_SRID_XREF_ID")
  USING INDEX  ENABLE;
  ALTER TABLE "ORACLE_3D_SRID_XREF" ADD CONSTRAINT "SRID3X_SPAT_REF_UK" UNIQUE ("ORACLE_SRID_XREF_ID", "VERTICAL_DATUM", "EPOCH", "VERTICAL_UNITS")
  USING INDEX  ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table ORACLE_3D_SRID_XREF
--------------------------------------------------------

  ALTER TABLE "ORACLE_3D_SRID_XREF" ADD CONSTRAINT "SRID3X_SRIDX_FK" FOREIGN KEY ("ORACLE_SRID_XREF_ID")
	  REFERENCES "ORACLE_SRID_XREF" ("ORACLE_SRID_XREF_ID") ENABLE;
