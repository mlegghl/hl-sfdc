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
     *  enterprise
     */
    public static helplightning.HLModelCall getEnterpriseCall(String callId) {
        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                      '/enterprise/sessions/' + callId);

        Object result = request.get();

        return HLModelCall.build(result);
    }

    /**
     * Create a new video session between two users based on
     *  their email addresses.
     *
     * @return the Id of the session
     */
    public static String makeEnterpriseCall(String dialerEmail, String receiverEmail) {
        Map<String, String> bodyParams = new Map<String, String>();
        bodyParams.put('dialer_email', dialerEmail);
        bodyParams.put('receiver_email', receiverEmail);

        helplightning.HLRequest request = new helplightning.HLRequest(helplightning.HLToken.build(),
                                                                      '/enterprise/calls');
        Object results = request.post(bodyParams);

        if (results != null) {
            Map<String, Object> resultsMap = (Map<String,Object>)results;

            return (String)resultsMap.get('id');
        } else {
            return null;
        }
    }

    /** User Methods **/

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

    public static Boolean sendPersonalRoomInvite(String userToken, String toName, String toEmail) {
        Map<String,String> params = new Map<String,String>();
        params.put('name', toName);
        params.put('email', toEmail);

        helplightning.HLRequest request = new helplightning.HLRequest(userToken,
                                                                      '/personal_room/invite');
        Object results = request.post(params);

        if (results == null)
            return false;
        else
            return true;
    }
}
