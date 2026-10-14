// Creates 500 Chatter Free users for testing the User Workspaces admin page.
// Run seed-users-2-configs.apex afterwards.
Integer COUNT = 500;

Profile p = [SELECT Id FROM Profile WHERE Name = 'Chatter Free User' LIMIT 1];
String suffix = UserInfo.getOrganizationId().left(15).toLowerCase();

List<User> users = new List<User>();
for (Integer i = 1; i <= COUNT; i++) {
    String n = String.valueOf(i).leftPad(3, '0');
    users.add(new User(
        FirstName = 'Seed',
        LastName = 'User ' + n,
        Alias = 'hls' + n,
        Email = 'hlseed' + n + '@example.com',
        UserName = 'hlseed' + n + '.' + suffix + '@example.com',
        ProfileId = p.Id,
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Chicago'));
}
insert users;
System.debug('Created ' + users.size() + ' users');
