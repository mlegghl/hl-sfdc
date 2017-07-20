/* -*- Mode: java; -*- */

/**
 * HLUserHelper.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLUserHelper {
    /**
     * Get our Help Lightning email
     *  address. This looks to see if
     *  we have an overridden email in
     *  our custom settings. If not, we
     *  fall back to using the Salesforce.com
     *  user email.
     */
    public static String getLogin() {
        Object l = HLConfiguration.getLoginOverride();

        if (l != null && (String)l != '') {
            return (String)l;
        } else {
            return Userinfo.getUserEmail();
        }
    }
}
