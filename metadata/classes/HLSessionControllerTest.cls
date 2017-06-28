/**
 * HLSessionControllerTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
private class HLSessionControllerTest {
    /**
     * Make sure we can get the necessary
     *  contact information for our supported
     *  records of type Case and WorkOrder
     */
    @isTest
    static void testGetContactForRecord() {
        // create a contact
        Contact contact = new Contact(FirstName = 'Contact',
                                      LastName = '1',
                                      Email = 'contact1@helplightning.com');
        insert contact;

        // create a case
        Case caseObj = new Case(Subject = 'Case 1',
                                Status = 'New',
                                Origin = 'Phone',
                                ContactId = contact.Id);
        insert caseObj;

        // create a work order
        WorkOrder workOrderObj = new WorkOrder(Subject = 'Work Order 1',
                                               ContactId = contact.Id);
        insert workOrderObj;

        // look up a valid case
        Contact c1 = HLSessionController.getContactForRecord('Case', caseObj.Id);
        System.assertNotEquals(c1, null);
        System.assertEquals(c1.Id, contact.Id);
        System.assertEquals(c1.Name, 'Contact 1');
        System.assertEquals(c1.Email, contact.Email);

        // look up a valid work order
        Contact c2 = HLSessionController.getContactForRecord('WorkOrder', workOrderObj.Id);
        System.debug('contact=' + c2);
        System.assertNotEquals(c2, null);
        System.assertEquals(c2.Id, contact.Id);
        System.assertEquals(c2.Name, 'Contact 1');
        System.assertEquals(c2.Email, contact.Email);

        // look up an invalid case and work order
        Contact c;
        c = HLSessionController.getContactForRecord('Case', workOrderObj.Id);
        System.assertEquals(c, null);
        c = HLSessionController.getContactForRecord('WorkOrder', caseObj.Id);
        System.assertEquals(c, null);

        // look up a valid case missing a contact
        Case case2Obj = new Case(Subject = 'Case 2',
                                 Status = 'New',
                                 Origin = 'Phone');
        insert case2Obj;
        c = HLSessionController.getContactForRecord('Case', case2Obj.Id);
        System.assertEquals(c, null);

        // look up an unsupported record type
        c = HLSessionController.getContactForRecord('Contact', contact.Id);
        System.assertEquals(c, null);
    }

}
