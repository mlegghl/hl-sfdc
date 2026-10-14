// Removes the seed users' config records so they no longer appear on the admin page.
// The users themselves are left in place (users can't be deleted, and the scratch org expires).
List<User> users = [SELECT Id FROM User WHERE UserName LIKE 'hlseed%@example.com'];
List<helplightning__Help_Lightning_Config__c> configs = [
    SELECT Id FROM helplightning__Help_Lightning_Config__c WHERE SetupOwnerId IN :users
];
delete configs;
System.debug('Deleted ' + configs.size() + ' config records');
