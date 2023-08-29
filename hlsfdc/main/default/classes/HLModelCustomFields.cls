/* -*- Mode: java; -*- */

/**
 * HLModelCustomFields.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLModelCustomFields {
  public HLModelCustomFields(Integer id, String name, String description,
                            Boolean hidden, String type, String valueAsString,
                            String mandatory, String defaultValue) {
      this.id = id;
      this.name = name;
      this.description = description;
      this.hidden = hidden;
      this.type = type;
      this.valueAsString = valueAsString;
      this.mandatory = mandatory;
      this.defaultValue = defaultValue;
  }

  public static HLModelCustomFields build(Object resultsObject) {
      Map<String,Object> s = (Map<String,Object>)resultsObject;

      Integer id = (Integer)s.get('id');
      String name = (String)s.get('name');
      String description = (String)s.get('description');
      Boolean hidden = (Boolean)s.get('hidden');
      String type = (String)s.get('type');
      String valueAsString = (String)s.get('valueAsString');
      String mandatory = (String)s.get('mandatory');
      String defaultValue = (String)s.get('defaultValue');

      return new HLModelCustomFields(id, name, description, hidden, type, valueAsString,
                                     mandatory, defaultValue);
  }

  @auraEnabled
  public Integer id;
  @auraEnabled
  public String name = '';
  @auraEnabled
  public String description = '';
  @auraEnabled
  public Boolean hidden = false;
  @auraEnabled
  public String type = '';
  @auraEnabled
  public String valueAsString = '';
  @auraEnabled
  public String mandatory = '';
  @auraEnabled
  public String defaultValue = '';
}
