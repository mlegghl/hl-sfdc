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
    * Get a list of available workspaces using a site level token
    */
    public static List<helplightning.HLModelWorkspace> getWorkspaces() {
      helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
      // This is a paginated API. It is likely, that there are more workspaces than are returned in a single page. We need to
      // paginate through ALL pages! In the future, I'd be good to define a general pagination method

      Boolean done = false;
      List<Object> entries = new List<Object>();

      Integer page = 1;
      while (done == false) {
          helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                        helplightning.HLToken.build(),
                                                                        '/v1r1/enterprise/workspaces');

          Map<String,String> queryParams = new Map<String,String>();
          queryParams.put('page', String.valueOf(page));

          Object result = request.get(queryParams);
          Map<String, Object> r = (Map<String,Object>)result;
          // get the entries
          List<Object> e = (List<Object>)r.get('entries');

          // add the entries into the all Results
          entries.addAll(e);

          // check if there are more pages to get
          Integer totalPages = (Integer)(r.get('total_pages'));
          if (totalPages <= page) {
              done = true;
          } else {
              page++;
          }
      }

      // Create a new object that has _all_ the entries
      Map<String, List<Object>> results = new Map<String, List<Object>>();
      results.put('entries', entries);

      // deserialize
      return HLModelWorkspace.buildMany(results);
    }

    /**
    * Get workspace by id
    */
    public static helplightning.HLModelWorkspace getWorkspaceById(String workspaceId) {
      helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
      helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                    helplightning.HLToken.build(),
                                                                    '/v1r1/enterprise/workspaces/' + workspaceId);
      Object result = request.get();

      // deserialize
      return HLModelWorkspace.build(result);
    }

    /**
     * Search amongst all the Help Lightning users for
     *  a registered user with a specific email address.
     */
    public static List<helplightning.HLModelSearchUser> searchUsers(String token, String searchTerm) {
        Map<String, Object> params = new Map<String, Object>();
        params.put('search_term', searchTerm);
        params.put('include_token', true);

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      token,
                                                                      '/v1/search');
        Object results = request.post(params);

        // deserialize
        return HLModelSearchUser.buildMany(results);
    }

    /** Enterprise Methods **/

    /**
     * Search amongst all the users in our enterprise.
     */
    public static List<helplightning.HLModelEnterpriseUser> searchEnterpriseUsers(String token, String email) {
        Map<String,String> params = new Map<String,String>();
        params.put('filter', 'email=' + email);

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      token,
                                                                      '/v1/enterprise/users');
        Object results = request.get(params);

        // deserialize
        return HLModelEnterpriseUser.buildMany(results);
    }

    /**
     * Get the details for a specific call in our
     *  enterprise. This uses the sessionId to search
     *  for a potential match.
     */
    public static List<helplightning.HLModelCall> getEnterpriseCall(String token, String sessionId) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      token,
                                                                      '/v1/enterprise/sessions/' + sessionId);

        Object results = request.get();

        return HLModelCall.buildMany(results);
    }

    /**
     * Get the details of a specific call, where we have the session and call id.
     */
    public static helplightning.HLModelCall getEnterpriseCallById(String token, String sessionId, String callId) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      token,
                                                                      '/v1/enterprise/calls/' + callId);
        Object result = request.get();

        return HLModelCall.buildFromCall(result, sessionId);
    }

    /**
     * Get the details of a workbox by the call id
     */
    public static helplightning.HLModelWorkboxDetails getWorkboxByCallId(String token, String callId) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      token,
                                                                      '/v1r1/enterprise/workboxes/by_call_id/' + callId);
        Object result = request.get();

        return HLModelWorkboxDetails.build(result);
    }

    /**
     * Save the custom fields for a workbox
     */
    public static Boolean saveCustomFields(String workboxToken, HLModelUpdateWorkbox payload) {
      helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
      Map<String,Object> params = new Map<String,Object>();
      params.put('values', payload.values);
      System.debug('saveCustomFields request body: ' + JSON.serialize(params));
      helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                    workboxToken,
                                                                    '/v1r1/workbox/custom_fields');
      Object result = request.put(params);
      System.debug('saveCustomFields result: ' + result);
      return (result != null);
    }

    /**
     * Close the workbox
     */
    public static Boolean closeWorkbox(String workboxToken) {
      helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
      Map<String,Object> params = new Map<String,Object>();
      helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                    workboxToken,
                                                                    '/v1r1/workbox/close');
      Object result = request.post(params);
      return (result != null);
    }

    /**
     * Reopen the workbox
     */
    public static Boolean reopenWorkbox(String workboxToken) {
      helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
      Map<String,Object> params = new Map<String,Object>();
      helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                    workboxToken,
                                                                    '/v1r1/workbox/reopen');
      Object result = request.post(params);
      return (result != null);
    }

    /** User Methods **/

    /**
     * Get the account info of a single user (us).
     */
    public static HLModelAccount getInfo(String userToken) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      userToken,
                                                                      '/v1/info');
        Object result = request.get();

        return HLModelAccount.build(userToken, result);
    }

    /**
     * Search for contacts
     */
    public static List<helplightning.HLModelEnterpriseUser> searchContacts(String token, String searchTerm) {
        Map<String,String> params = new Map<String,String>();
        params.put('order', 'name');
        if (!String.isEmpty(searchTerm)) {
            params.put('filter', 'name~=' + '%' + searchTerm + '%');
        }

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      token,
                                                                      '/v1r1/enterprise/users');
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

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      userToken,
                                                                      '/v1/sessions');
        Object result = request.post(sessionParams);

        return HLModelSession.build(result);
    }

    /**
     * Get info about an existing session
     */
    public static HLModelSession getSession(String userToken, String sessionId) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      userToken,
                                                                      '/v1/sessions/' + sessionId);
        Object result = request.get();

        return HLModelSession.build(result);
    }

    /**
     * Request video on a session
     */
    public static HLModelVideoSession sessionRequestVideo(String userToken, HLModelSession session) {
        Map<String,String> videoParams = new Map<String,String>();
        videoParams.put('user_token', userToken);

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      session.token,
                                                                      '/v1/session/video');
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

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      userToken,
                                                                      '/v1/sessions/link/invite');
        Object results = request.post(params);

        if (results == null)
            return false;
        else
            return true;
    }

    /**
     * Send a workbox invite to a guest user via email or phone.
     * Requires a workbox token (not user token).
     * Returns the workbox response.
     */
    public static Map<String,Object> sendWorkboxInvite(String workboxToken, String email, String phone, String name) {
        Map<String,String> params = new Map<String,String>();
        params.put('action', 'join_session');
        if (!String.isEmpty(email)) {
            params.put('email', email);
        }
        if (!String.isEmpty(phone)) {
            params.put('phone', phone);
        }
        if (!String.isEmpty(name)) {
            params.put('name', name);
        }

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      workboxToken,
                                                                      '/v1r1/workbox/invite');
        Object results = request.post(params);

        if (results == null) {
            return null;
        }

        return (Map<String,Object>)results;
    }

    /**
     * Create a new workbox (help thread).
     * Returns the workbox response containing the workbox id and token.
     */
    public static Map<String,Object> createWorkbox(String userToken, String title) {
        Map<String,Object> params = new Map<String,Object>();
        if (!String.isEmpty(title)) {
            params.put('title', title);
        }
        params.put('participants', new List<String>());

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      userToken,
                                                                      '/v1r1/workboxes');
        Object results = request.post(params);

        if (results == null) {
            return null;
        }

        return (Map<String,Object>)results;
    }

    /**
     * Create a workbox invite silently (without sending email/SMS).
     * This invites a guest to an existing workbox and returns a link that can be copied and shared.
     * Requires a workbox token (not user token).
     * Returns the response containing the link and workbox info.
     */
    public static Map<String,Object> createWorkboxInviteSilent(String workboxToken, String name) {
        Map<String,String> params = new Map<String,String>();
        params.put('action', 'join_session');
        params.put('name', name);

        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      workboxToken,
                                                                      '/v1r1/workbox/invite/silent');
        Object results = request.post(params);

        if (results == null) {
            return null;
        }

        return (Map<String,Object>)results;
    }

    /**
     * Get a workbox by its ID.
     * Returns fresh workbox info including the token.
     */
    public static helplightning.HLModelWorkboxDetails getWorkboxById(String userToken, Integer workboxId) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      userToken,
                                                                      '/v1r1/workboxes/' + workboxId);
        Object result = request.get();

        // Use buildDirect since this endpoint returns workbox data directly (no 'workbox' wrapper)
        return HLModelWorkboxDetails.buildDirect(result);
    }

    /**
     * Create a one time use link
     */
    public static HLModelSessionLink createOneTimeUseLink(String userToken) {
      Map<String,String> params = new Map<String,String>();
      params.put('linkType', 'otu');
      helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
      helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                    userToken,
                                                                    '/v1/sessions/link');
      Object results = request.post(params);

      return HLModelSessionLink.build(results);
    }

    /**
     * Get attachments for a call
     */
    public static List<helplightning.HLModelAttachment> getAttachments(String token, String callId) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      token,
                                                                      '/v1r1/enterprise/calls/' + callId + '/attachments');
        Object results = request.get();

        // deserialize
        return HLModelAttachment.buildMany(results);
    }

    /**
     * Resend invite to a guest in a workbox.
     * Requires a workbox token and the guest's UUID.
     */
    public static Map<String,Object> resendGuestInvite(String workboxToken, String guestUuid) {
        Map<String,Object> params = new Map<String,Object>();
        // Empty object for chat invite, or { action: 'join_session' } for video
        
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      workboxToken,
                                                                      '/v1r1/workbox/invite/' + guestUuid);
        Object result = request.post(params);

        if (result == null) {
            return null;
        }

        return (Map<String,Object>)result;
    }

    /**
     * Remove a guest from a workbox.
     * Requires a workbox token and the guest's UUID.
     */
    public static Boolean removeGuestFromWorkbox(String workboxToken, String guestUuid) {
        helplightning.HLEnvironment environment = new helplightning.HLEnvironment(helplightning.HLConfiguration.getEnvironment());
        helplightning.HLRequest request = new helplightning.HLRequest(environment,
                                                                      workboxToken,
                                                                      '/v1r1/workbox/invite/' + guestUuid);
        // DELETE request
        Object result = request.del();
        return true;
    }
}
