/* -*- Mode: java; -*- */

/**
 * HLModelAttachmentTest.cls
 *
 * Copyright (c) 2021 HelpLightning Inc.
 * https://helplightning.com
 */

@isTest
public class HLModelAttachmentTest {
    @isTest
    static void testBuildMany() {
        Object l = JSON.deserializeUntyped(HLModelAttachmentTest.resultsMany);
        List<helplightning.HLModelAttachment> attachments = helplightning.HLModelAttachment.buildMany(l);

        System.assertEquals(attachments.size(), 1);

        // verify the first object
        helplightning.HLModelAttachment a = attachments.get(0);
        System.assertEquals(a.id, 202255);
        System.assertEquals(a.type, 'incall');
        System.assertEquals(a.thumbnail, 'https://helplightning-proda-call-data.s3.us-east-1.amazonaws.com');
        System.assertEquals(a.status, '');
        System.assertEquals(a.signedUrl, 'https://helplightning-proda-call-data.s3.us-east-1.amazonaws.com');
        System.assertEquals(a.mimeType, 'image/jpeg');
        System.assertEquals(a.fileName, 'IMG_CAP_11-04-2021 10-31-27.JPG');
    }

    @isTest
    static void testBuildManyWithEmptyResults() {
        Object o = JSON.deserializeUntyped(HLModelAttachmentTest.emptyResults);
        List<helplightning.HLModelAttachment> attachments = helplightning.HLModelAttachment.buildMany(o);

        System.assertEquals(attachments.size(), 0);
    }

    @isTest
    static void testBuildManyWithNullResults() {
        List<helplightning.HLModelAttachment> attachments = helplightning.HLModelAttachment.buildMany(null);

        System.assertEquals(attachments.size(), 0);
    }

    @isTest
    static void testSerialize() {
        Object o = JSON.deserializeUntyped(HLModelAttachmentTest.resultsMany);
        List<helplightning.HLModelAttachment> attachments = helplightning.HLModelAttachment.buildMany(o);

        // get the first attachment, and reserialize it
        helplightning.HLModelAttachment a = attachments.get(0);

        Map<String,Object> serialized = a.serialize();
        System.assertEquals(serialized.get('id'), (Object)202255);
        System.assertEquals(serialized.get('type'), (Object)'incall');
        System.assertEquals(serialized.get('thumbnail'), (Object)'https://helplightning-proda-call-data.s3.us-east-1.amazonaws.com');
        System.assertEquals(serialized.get('status'), (Object)'');
        System.assertEquals(serialized.get('signed_url'), (Object)'https://helplightning-proda-call-data.s3.us-east-1.amazonaws.com');
        System.assertEquals(serialized.get('mime_type'), (Object)'image/jpeg');
        System.assertEquals(serialized.get('name'), (Object)'IMG_CAP_11-04-2021 10-31-27.JPG');
    }

    private static String resultsMany = '[{"id":202255,"type":"incall","thumbnail":"https://helplightning-proda-call-data.s3.us-east-1.amazonaws.com","status":"","signed_url":"https://helplightning-proda-call-data.s3.us-east-1.amazonaws.com","mime_type":"image/jpeg","name":"IMG_CAP_11-04-2021 10-31-27.JPG"}]';

    private static String emptyResults = '[]';

}
