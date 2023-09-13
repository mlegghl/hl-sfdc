/* -*- Mode: java; -*- */

/**
 * HLTokenHelper.cls
 *
 * Copyright (c) 2023 HelpLightning Inc.
 * https://helplightning.com
 */

 public class HLTokenHelper {
  public static String getToken() {
    
    if (helplightning.HLConfiguration.getHasSiteKey()) {
      helplightning.HLModelWorkspace workspace = helplightning.HLGaldrClient.getWorkspaceById(HLConfiguration.getWorkspaceId());

      if (workspace != null) {
        return workspace.token;
      } else {
        throw new AuraHandledException('Configured workspace was not found in get_workspace_by_id.');
      }

    } else {
      return helplightning.HLToken.build();
    }
  }
}
