// Gives the seed users Help Lightning config records with a mix of workspaces.
// Fill in workspace ids from your site (the bulk dropdown on the admin page shows "Name (ID)").
List<String> ACTIVE_IDS = new List<String>{ '24940', '24943' };
// Leave empty if your site has no deactivated workspace; those rows become "Not found" instead.
List<String> DEACTIVATED_IDS = new List<String>{ '25048' };
String MISSING_ID = '999999999';

List<User> users = [
    SELECT Id, Email FROM User
    WHERE UserName LIKE 'hlseed%@example.com'
    ORDER BY UserName
];

Set<Id> existing = new Set<Id>();
for (helplightning__Help_Lightning_Config__c c : [
        SELECT SetupOwnerId FROM helplightning__Help_Lightning_Config__c
        WHERE SetupOwnerId IN :users]) {
    existing.add(c.SetupOwnerId);
}

List<helplightning__Help_Lightning_Config__c> configs = new List<helplightning__Help_Lightning_Config__c>();
for (Integer i = 0; i < users.size(); i++) {
    User u = users[i];
    if (existing.contains(u.Id)) {
        continue;
    }
    helplightning__Help_Lightning_Config__c c = new helplightning__Help_Lightning_Config__c(SetupOwnerId = u.Id);
    Integer bucket = Math.mod(i, 10);
    if (bucket < 6) {
        // 60% active
        c.helplightning__Workspace_Id__c = ACTIVE_IDS[Math.mod(i, ACTIVE_IDS.size())];
    } else if (bucket < 9) {
        // 30% deactivated (or missing if none were provided)
        c.helplightning__Workspace_Id__c = DEACTIVATED_IDS.isEmpty()
            ? MISSING_ID
            : DEACTIVATED_IDS[Math.mod(i, DEACTIVATED_IDS.size())];
    } else {
        // 10% missing
        c.helplightning__Workspace_Id__c = MISSING_ID;
    }
    // every 7th user also has an email override
    if (Math.mod(i, 7) == 0) {
        c.helplightning__Login__c = u.Email.replace('@', '+hl@');
    }
    configs.add(c);
}
insert configs;
System.debug('Created ' + configs.size() + ' config records');
