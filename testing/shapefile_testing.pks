create or replace PACKAGE SHAPEFILE_TESTING AS 
  testData blob;
  --%suite(Shapefile)
  
  --%beforeall
  procedure setUp;
  
  --%test(Empty shapefile)
  procedure testEmptyShapefile;
  
  --%test(Read point shapefile)
  procedure testPointShapefileReader;
  
  --%test(Read line shapefile)
  procedure testLineShapefileReader;
  
  --%test(Read polygon shapefile)
  procedure testPolygonShapefileReader;
  
  --%test(Read multipoint shapefile)
  procedure testMultiPointShapefileReader;
  
  --%test(Read point z shapefile)
  procedure testPointZShapefileReader;
  
  --%test(Read line z shapefile)
  procedure testLineZShapefileReader;
  
  --%test(Read polygon z shapefile)
  procedure testPolygonZShapefileReader;
  
  --%test(Read multipoint z shapefile)
  procedure testMultiPointZShapefileReader;
  
    --%test(Read point m shapefile)
  procedure testPointMShapefileReader;
  
  --%test(Read line m shapefile)
  procedure testLineMShapefileReader;
  
  --%test(Read polygon m shapefile)
  procedure testPolygonMShapefileReader;
  
  --%test(Read multipoint m shapefile)
  procedure testMultiPointMShapefileReader;
  
  --%test(Read null)
  procedure testNullShapefileReader;
  
  --%test(Read non-existent shapefile)
  procedure testNonexistentShapefile;
  
  --%test(Read invalid shapefile)
  procedure testInvalidShapefile;
  
  --%test(Read shapefile with missing component)
  procedure testMissingShapefileComponent;

  --%test(Write point shapefile)
  procedure testPointShapefileWriter;
  
  --%test(Write line shapefile)
  procedure testLineShapefileWriter;
  
END SHAPEFILE_TESTING;