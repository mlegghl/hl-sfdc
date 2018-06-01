/* -*- Mode: java; -*- */

/**
 * HLModelCallUserTest.cls
 *
 * Copyright (c) 2017 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelCallUserTest {
    @isTest
    public static void build() {
        Object o = JSON.deserializeUntyped(HLModelCallUserTest.result);
        helplightning.HLModelCallUser u = helplightning.HLModelCallUser.build(o);

        System.assertEquals('5', u.id);
        System.assertEquals('Small User2', u.name);
    }

    private static String result = '{"name":"Small User2","id":"5","email":"small_u2@helplightning.com"}';
}
