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
        Map<String, Object> params = new Map<String, Object>();
        params.put('search_term', searchTerm);
        params.put('include_token', true);

        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                      '/search');
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

        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                      '/enterprise/users');
        Object results = request.get(params);

        // deserialize
        return HLModelEnterpriseUser.buildMany(results);
    }

    /**
     * Get the details for a specific call in our
     *  enterprise. This uses the sessionId to search
     *  for a potential match.
     */
    public static List<helplightning.HLModelCall> getEnterpriseCall(String sessionId) {
        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                      '/enterprise/sessions/' + sessionId);

        Object results = request.get();

        return HLModelCall.buildMany(results);
    }

    /**
     * Get the details of a specific call, where we have the session and call id.
     */
    public static helplightning.HLModelCall getEnterpriseCallById(String sessionId, String callId) {
        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                      '/enterprise/calls/' + callId);
        Object result = request.get();

        return HLModelCall.buildFromCall(result, sessionId);
    }

    /** User Methods **/

    /**
     * Get the account info of a single user (us).
     */
    public static HLModelAccount getInfo(String userToken) {
        helplightning.HLRequest request = new helplightning.HLRequest(userToken,
                                                                      '/info');
        Object result = request.get();

        return HLModelAccount.build(userToken, result);
    }

    /**
     * Search for contacts
     */
    public static List<helplightning.HLModelEnterpriseUser> searchContacts(String searchTerm) {
        Map<String,String> params = new Map<String,String>();
        if (!String.isEmpty(searchTerm)) {
            params.put('filter', 'name~=' + '%' + searchTerm + '%');
        }

        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                      '/enterprise/users');
        Object results = request.get(params);

        // deserialize
        return HLModelEnterpriseUser.buildMany(results);
    }

    /**
     * Create a new session with some other users.
     */
    public static HLModelSession createSession(String userToken, List<String> contactTokens) {
        Map<String,Object> sessionParams = new Map<String,Object>();
        sessionParams.put('contact_tokens', contactTokens);

        helplightning.HLRequest request = new helplightning.HLRequest(userToken,
                                                                      '/sessions');
        Object result = request.post(sessionParams);

        return HLModelSession.build(result);
    }

    /**
     * Get info about an existing session
     */
    public static HLModelSession getSession(String userToken, String sessionId) {
        helplightning.HLRequest request = new helplightning.HLRequest(userToken,
                                                                      '/sessions/' + sessionId);
        Object result = request.get();

        return HLModelSession.build(result);
    }

    /**
     * Request video on a session
     */
    public static HLModelVideoSession sessionRequestVideo(String userToken, HLModelSession session) {
        Map<String,String> videoParams = new Map<String,String>();
        videoParams.put('user_token', userToken);

        helplightning.HLRequest request = new helplightning.HLRequest(session.token,
                                                                      '/session/video');
        Object results = request.post(videoParams);

        return HLModelVideoSession.build(results);
    }

    public static Boolean sendOneTimeUseLink(String userToken, String toName, String toEmail, String toPhone, String message) {
        Map<String,String> params = new Map<String,String>();
        params.put('name', toName);
        params.put('recipientEmail', toEmail);
        params.put('recipientPhoneNumber', toPhone);
        params.put('linkType', '2');
        params.put('message', message);

        helplightning.HLRequest request = new helplightning.HLRequest(userToken,
                                                                      '/sessions/link/invite');
        Object results = request.post(params);

        if (results == null)
            return false;
        else
            return true;
    }
}
