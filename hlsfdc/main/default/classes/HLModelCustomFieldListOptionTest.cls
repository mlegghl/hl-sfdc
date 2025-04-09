/* -*- Mode: java; -*- */

/**
 * HLModelCustomFieldListOptionTest.cls
 *
 * Copyright (c) 2023 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelCustomFieldListOptionTest {
    @isTest
    static void testBuild() {
        // Create a test map with the required fields
        Map<String, Object> testMap = new Map<String, Object>{
            'name' => 'Test Option',
            'id' => 456
        };
        
        // Call the build method
        HLModelCustomFieldListOption option = HLModelCustomFieldListOption.build(testMap);
        
        // Verify the properties were set correctly
        System.assertNotEquals(null, option, 'Option should not be null');
        System.assertEquals('Test Option', option.label, 'Label should be set correctly');
        System.assertEquals(456, option.value, 'Value should be set correctly');
    }
    
    @isTest
    static void testBuildWithNull() {
        // Test the build method with null input
        HLModelCustomFieldListOption option = HLModelCustomFieldListOption.build(null);
        
        // Verify the result is null
        System.assertEquals(null, option, 'Option should be null when input is null');
    }
    
    @isTest
    static void testIntegrationWithHLModelCustomFields() {
        // Create a test map with options
        Map<String, Object> testMap = new Map<String, Object>{
            'id' => 789,
            'name' => 'Test Field',
            'description' => 'Test Description',
            'hidden' => false,
            'type' => 'LIST',
            'valueAsString' => 'Test Value',
            'mandatory' => 'MANDATORY_ON_CREATION',
            'defaultValue' => null,
            'multiSelect' => false,
            'options' => new List<Object>{
                new Map<String, Object>{
                    'name' => 'Option 1',
                    'id' => 1
                }
            }
        };
        
        HLModelCustomFields customField = HLModelCustomFields.build(testMap);
        
        // Verify the custom field was built correctly
        System.assertNotEquals(null, customField, 'Custom field should not be null');
        System.assertEquals(789, customField.id, 'ID should be set correctly');
        System.assertEquals('Test Field', customField.name, 'Name should be set correctly');
        
        // Verify the first option
        HLModelCustomFieldListOption option1 = customField.options[0];
        System.assertEquals('Option 1', option1.label, 'First option label should be set correctly');
        System.assertEquals(1, option1.value, 'First option value should be set correctly');
    }
} 