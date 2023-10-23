/* -*- Mode: java; -*- */

/**
 * HLModelWorkspaceTest.cls
 *
 * Copyright (c) 2023 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelWorkspaceTest {
  @isTest
  static void testBuildMany() {
      Object o = JSON.deserializeUntyped(HLModelWorkspaceTest.resultsMany);
      List<helplightning.HLModelWorkspace> ws = helplightning.HLModelWorkspace.buildMany(o);

      System.assertEquals(ws.size(), 1);

      // verify the first object
      helplightning.HLModelWorkspace u = ws.get(0);
      System.assertEquals(u.id, 3);
      System.assertEquals(u.name, 'Small Admin');
      System.assertEquals(u.token, '123456');
      System.assertEquals(u.active, false);
  }

  @isTest
  static void testBuildManyWithEmptyResults() {
      Object o = JSON.deserializeUntyped(HLModelWorkspaceTest.emptyResults);
      List<helplightning.HLModelWorkspace> ws = helplightning.HLModelWorkspace.buildMany(o);

      System.assertEquals(ws.size(), 0);
  }

  @isTest
  static void testBuildManyWithNullResults() {
      List<helplightning.HLModelWorkspace> ws = helplightning.HLModelWorkspace.buildMany(null);

      System.assertEquals(ws.size(), 0);
  }

  @isTest
  static void testSerialize() {
      Object o = JSON.deserializeUntyped(HLModelWorkspaceTest.resultsMany);
      List<helplightning.HLModelWorkspace> ws = helplightning.HLModelWorkspace.buildMany(o);

      helplightning.HLModelWorkspace u = ws.get(0);

      Map<String,Object> serialized = u.serialize();
      System.assertEquals(serialized.get('id'), (Object)3);
      System.assertEquals(serialized.get('name'), (Object)'Small Admin');
      System.assertEquals(serialized.get('token'), (Object)'123456');
      System.assertEquals(serialized.get('active'), (Object)false);
  }

  private static String resultsMany = '{"entries":[{"id":3,"name": "Small Admin","token":"123456","active":false}],"page":1,"page_size":1,"total_entries":1,"total_pages":1}';

  private static String emptyResults = '{"entries":[],"page":1,"page_size":1,"total_entries":0,"total_pages":1}';
}
