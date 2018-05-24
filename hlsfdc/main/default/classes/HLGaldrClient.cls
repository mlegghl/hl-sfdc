/* -*- Mode: java; -*- */

/**
 * HLGaldrClient.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLGaldrClient {
    /**
     * This is an interface for making requests
     *  to the Galdr RESTful API
     */

    /**
     * Search amongst all the Help Lightning users for
     *  a registered user with a specific email address.
     */
    public static List<helplightning.HLModelSearchUser> searchUsers(String searchTerm) {
        Map<String, String> params = new Map<String, String>();
        params.put('search_term', searchTerm);

        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(), '/search');
        Object results = request.post(params);

        // deserialize
        return HLModelSearchUser.buildMany(results);
    }

    /** Enterprise Methods **/

    /**
     * Search amongst all the users in our enterprise.
     */
    public static List<helplightning.HLModelEnterpriseUser> searchEnterpriseUsers(String email) {
        Map<String,String> params = new Map<String,String>();
        params.put('filter', 'email=' + email);

        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(), '/enterprise/users');
        Object results = request.get(params);

        // deserialize
        return HLModelEnterpriseUser.buildMany(results);
    }



    /** User Methods **/
    public static Boolean sendPersonalRoomInvite(String userToken, String toName, String toEmail) {
        Map<String,String> params = new Map<String,String>();
        params.put('name', toName);
        params.put('email', toEmail);

        helplightning.HLRequest request = new helplightning.HLRequest(userToken, '/personal_room/invite');
        Object results = request.post(params);

        if (results == null)
            return false;
        else
            return true;
    }
}
