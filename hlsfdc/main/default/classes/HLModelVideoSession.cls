/* -*- Mode: java; -*- */

/**
 * HLModelVideoSession.cls
 *
 * Copyright (c) 2018 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLModelVideoSession {
    /**
     * This is the model that represents
     *  a Help Lightning Video Session object.
     *  which includes everything needed to
     *  connect to Gss.
     */

    /**
     * Build a new model from a JSON
     *  response object
     */
    public static HLModelVideoSession build(Object sessionObject) {
        return new HLModelVideoSession();
    }
}
