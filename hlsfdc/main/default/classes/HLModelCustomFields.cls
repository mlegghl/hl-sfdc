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
                            String mandatory, Object defaultValue, Boolean multiSelect,
                            List<HLModelCustomFieldListOption> options) {
      this.id = id;
      this.name = name;
      this.description = description;
      this.hidden = hidden;
      this.type = type;
      this.valueAsString = valueAsString;
      this.mandatory = mandatory;
      this.defaultValue = defaultValue;
      this.multiSelect = multiSelect;
      this.options = options;
  }

  public static HLModelCustomFields build(Object resultsObject) {
      Map<String,Object> s = (Map<String,Object>)resultsObject;
      List<HLModelCustomFieldListOption> options = new List<HLModelCustomFieldListOption>();

      Integer id = (Integer)s.get('id');
      String name = (String)s.get('name');
      String description = (String)s.get('description');
      Boolean hidden = (Boolean)s.get('hidden');
      String type = (String)s.get('type');
      String valueAsString = (String)s.get('valueAsString');
      String mandatory = (String)s.get('mandatory');
      Object defaultValue = s.get('defaultValue');
      Boolean multiSelect = (Boolean)s.get('multiSelect');
      
      List<Object> optEntries = (List<Object>)s.get('options');

      // iterate through the cf options if found, building models
      if (optEntries != null) {
        for (Object u: optEntries) {
          options.add(HLModelCustomFieldListOption.build(u));
        }
      }

      return new HLModelCustomFields(id, name, description, hidden, type, valueAsString,
                                     mandatory, defaultValue, multiSelect, options);
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
  public Object defaultValue;
  @auraEnabled
  public Boolean multiSelect = false;
  @auraEnabled
  public List<HLModelCustomFieldListOption> options = new List<HLModelCustomFieldListOption>();
}
