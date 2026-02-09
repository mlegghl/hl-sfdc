/* -*- Mode: java; -*- */

/**
 * HLModelWorkboxDetailsTest.cls
 *
 * Unit tests for HLModelWorkboxDetails model class.
 */
@isTest
public class HLModelWorkboxDetailsTest {

    @isTest
    static void testBuildWithNullInput() {
        // Test build() with null input
        HLModelWorkboxDetails result = HLModelWorkboxDetails.build(null);
        System.assertEquals(null, result, 'build(null) should return null');
    }

    @isTest
    static void testBuildWithNullWorkboxWrapper() {
        // Test build() when 'workbox' key is missing/null (covers line 29)
        Map<String,Object> input = new Map<String,Object>();
        input.put('other_key', 'some_value');
        // No 'workbox' key
        
        HLModelWorkboxDetails result = HLModelWorkboxDetails.build(input);
        System.assertEquals(null, result, 'build() with missing workbox key should return null');
    }

    @isTest
    static void testBuildDirectWithNullInput() {
        // Test buildDirect() with null input (covers line 38)
        HLModelWorkboxDetails result = HLModelWorkboxDetails.buildDirect(null);
        System.assertEquals(null, result, 'buildDirect(null) should return null');
    }

    @isTest
    static void testBuildDirectWithFullData() {
        // Build a complete workbox response to cover all parsing paths
        Map<String,Object> workboxData = new Map<String,Object>();
        workboxData.put('id', 12345);
        workboxData.put('token', 'test_token_abc');
        workboxData.put('status', 'REPORTED');
        workboxData.put('title', 'Case - 00001234');

        // Add participants (covers lines 68-69)
        List<Object> participants = new List<Object>();
        Map<String,Object> participant1 = new Map<String,Object>();
        participant1.put('id', 100);
        participant1.put('name', 'John Doe');
        participant1.put('owner', true);
        participants.add(participant1);
        
        Map<String,Object> participant2 = new Map<String,Object>();
        participant2.put('id', 101);
        participant2.put('name', 'Jane Smith');
        participant2.put('owner', false);
        participants.add(participant2);
        workboxData.put('participants', participants);

        // Add guests
        List<Object> guests = new List<Object>();
        Map<String,Object> guest1 = new Map<String,Object>();
        guest1.put('id', 200);
        guest1.put('name', 'Guest User');
        guest1.put('uuid', 'uuid-123-abc');
        guest1.put('has_joined', true);
        guests.add(guest1);
        
        Map<String,Object> guest2 = new Map<String,Object>();
        guest2.put('id', 201);
        guest2.put('name', 'Pending Guest');
        guest2.put('uuid', 'uuid-456-def');
        guest2.put('has_joined', false);
        guests.add(guest2);
        workboxData.put('guests', guests);

        // Add field values
        List<Object> fieldValues = new List<Object>();
        Map<String,Object> fv1 = new Map<String,Object>();
        fv1.put('id', 1);
        fv1.put('value', 'text value');
        fv1.put('type', 'TEXT');
        fv1.put('multiSelect', false);
        fieldValues.add(fv1);
        
        Map<String,Object> fv2 = new Map<String,Object>();
        fv2.put('id', 2);
        fv2.put('value', true);
        fv2.put('type', 'BOOLEAN');
        fv2.put('multiSelect', false);
        fieldValues.add(fv2);
        workboxData.put('fields', fieldValues);

        // Add ticketFieldsFull (empty list to test the null check path)
        workboxData.put('ticketFieldsFull', new List<Object>());

        // Test buildDirect
        HLModelWorkboxDetails result = HLModelWorkboxDetails.buildDirect(workboxData);

        // Verify basic fields
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(12345, result.workboxId, 'workboxId should match');
        System.assertEquals('test_token_abc', result.workboxToken, 'workboxToken should match');
        System.assertEquals('REPORTED', result.status, 'status should match');
        System.assertEquals('Case - 00001234', result.title, 'title should match');

        // Verify participants
        System.assertEquals(2, result.participants.size(), 'Should have 2 participants');
        System.assertEquals(100, result.participants[0].id, 'First participant id should match');
        System.assertEquals('John Doe', result.participants[0].name, 'First participant name should match');
        System.assertEquals(true, result.participants[0].owner, 'First participant should be owner');
        System.assertEquals(false, result.participants[1].owner, 'Second participant should not be owner');

        // Verify guests
        System.assertEquals(2, result.guests.size(), 'Should have 2 guests');
        System.assertEquals(200, result.guests[0].id, 'First guest id should match');
        System.assertEquals('Guest User', result.guests[0].name, 'First guest name should match');
        System.assertEquals('uuid-123-abc', result.guests[0].uuid, 'First guest uuid should match');
        System.assertEquals(true, result.guests[0].has_joined, 'First guest should have joined');
        System.assertEquals(false, result.guests[1].has_joined, 'Second guest should not have joined');

        // Verify field values
        System.assertEquals(2, result.fieldValues.size(), 'Should have 2 field values');
        System.assertEquals(1, result.fieldValues[0].id, 'First field id should match');
        System.assertEquals('text value', result.fieldValues[0].value, 'First field value should match');
        System.assertEquals('TEXT', result.fieldValues[0].fieldType, 'First field type should match');
        System.assertEquals(false, result.fieldValues[0].multiSelect, 'First field should not be multiSelect');
    }

    @isTest
    static void testBuildWithWorkboxWrapper() {
        // Test build() with proper 'workbox' wrapper structure
        Map<String,Object> workboxData = new Map<String,Object>();
        workboxData.put('id', 99999);
        workboxData.put('token', 'wrapped_token');
        workboxData.put('status', 'CLOSED');
        workboxData.put('title', 'Work Order - 00005678');

        Map<String,Object> wrapper = new Map<String,Object>();
        wrapper.put('workbox', workboxData);

        HLModelWorkboxDetails result = HLModelWorkboxDetails.build(wrapper);

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(99999, result.workboxId, 'workboxId should match');
        System.assertEquals('wrapped_token', result.workboxToken, 'workboxToken should match');
        System.assertEquals('CLOSED', result.status, 'status should match');
    }

    @isTest
    static void testBuildWithMinimalData() {
        // Test with minimal data (no participants, guests, or fields)
        Map<String,Object> workboxData = new Map<String,Object>();
        workboxData.put('id', 1);
        workboxData.put('token', 'min_token');
        workboxData.put('status', 'REPORTED');

        HLModelWorkboxDetails result = HLModelWorkboxDetails.buildDirect(workboxData);

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.participants.size(), 'Should have 0 participants');
        System.assertEquals(0, result.guests.size(), 'Should have 0 guests');
        System.assertEquals(0, result.fieldValues.size(), 'Should have 0 field values');
    }

    @isTest
    static void testConstructor() {
        // Test the constructor directly
        List<helplightning.HLModelCustomFields> customFields = new List<helplightning.HLModelCustomFields>();
        
        HLModelWorkboxDetails details = new HLModelWorkboxDetails(123, 'my_token', 'REPORTED', customFields);
        
        System.assertEquals(123, details.workboxId, 'workboxId should match');
        System.assertEquals('my_token', details.workboxToken, 'workboxToken should match');
        System.assertEquals('REPORTED', details.status, 'status should match');
        System.assertEquals(0, details.customFields.size(), 'customFields should be empty');
    }
}
