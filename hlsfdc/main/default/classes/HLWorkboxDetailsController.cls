/* -*- Mode: java; -*- */

/**
 * HLWorkboxDetailsController.cls
 *
 * Copyright (c) 2021 HelpLightning Inc.
 * https://helplightning.com
 */
public with sharing class HLWorkboxDetailsController {

  @AuraEnabled(cacheable=true)
  public static HLModelWorkboxDetails getWorkboxDetails(Integer workboxId) {
      try {
          System.debug('Getting workbox details for workboxId: ' + workboxId);
          String myUserEmail = helplightning.HLUserHelper.getLogin();
          String token = HLTokenHelper.getToken();
          

          // first get a list of users to find us, since
          //  we have to make this request as a specific user
          List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
          if (users == null || users.size() == 0) {
              System.debug('Error finding our user.');
              return null;
          }

          // use the first user.
          String userToken = users.get(0).authToken;
          if (userToken == null) {
              System.debug('Invalid user token');
              return null;
          }
          helplightning.HLModelWorkboxInfo ticket = helplightning.HLGaldrClient.getTicketId(token, workboxId);
          System.debug('Got ticket: ' + ticket);
          helplightning.HLModelWorkboxDetails details = helplightning.HLGaldrClient.getWorkboxDetails(userToken, ticket.ticketId);
          System.debug('Got workbox details: ' + details);
          return details;

      } catch (helplightning.HLConfigurationException e) {
          throw new AuraHandledException('The Help Lightning component must be configured first.');
      }
  }

  @AuraEnabled(cacheable=true)
  public static Boolean closeWorkbox(HLModelCloseWorkbox payload) {
      try {
          System.debug('Saving workbox: ' + payload);
          String myUserEmail = helplightning.HLUserHelper.getLogin();
          String token = HLTokenHelper.getToken();
          

          // first get a list of users to find us, since
          //  we have to make this request as a specific user
          List<helplightning.HLModelEnterpriseUser> users = helplightning.HLGaldrClient.searchEnterpriseUsers(token, myUserEmail);
          if (users == null || users.size() == 0) {
              System.debug('Error finding our user.');
              return null;
          }

          // use the first user.
          String userToken = users.get(0).authToken;
          if (userToken == null) {
              System.debug('Invalid user token');
              return null;
          }

          helplightning.HLGaldrClient.closeWorkbox(userToken, payload);
          
          return true;

      } catch (helplightning.HLConfigurationException e) {
          throw new AuraHandledException('The Help Lightning component must be configured first.');
      }
  }
}