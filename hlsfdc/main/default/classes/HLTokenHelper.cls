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
      return workspace.token;
    } else {
      return helplightning.HLToken.build();
    }
    
  }
}
