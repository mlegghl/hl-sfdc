/* -*- Mode: java; -*- */

/**
 * HLEnvironment.cls
 *
 * Copyright (c) 2024 HelpLightning Inc.
 * https://helplightning.com
 */

public class HLEnvironment {
    public String api_key = null;
    public String api_url = null;
    public String url = null;


    // This is the API Key for the SalesForce Integration App developed
    //  by Help Lightning.
    private static final String US_API_KEY = '01e0bbdecb85a1f83bf6ade3624af03b';
    private static final String EU_API_KEY = 'nmp2ovlzdnzhwej2zmvtdw4rzncwzz09';
    private static final String DEV_API_KEY = '9BoKBM2MQ27nPdHW0XckRw';

    // Help Lightning API Endpoints
    private static final String US_API_URL = 'https://api.helplightning.net/api';
    private static final String EU_API_URL = 'https://api.eu1.helplightning.net/api';
    private static final String DEV_API_URL = 'https://api.dev.helplightning.net/api';

    // Help Lightning Web Endpoints
    private static final String US_URL = 'https://helplightning.net';
    private static final String EU_URL = 'https://app.eu1.helplightning.net';
    private static final String DEV_URL = 'https://app.dev.helplightning.net';

    private static final Map<String, Map<String,String>> ENVIRONMENTS;


    // Static initializer block to initialize the nested map
    static {
        Map<String, String> usConfig = new Map<String, String>{
                'api_key' => US_API_KEY,
                'api_url' => US_API_URL,
                'url' => US_URL
                };

        Map<String, String> euConfig = new Map<String, String>{
                'api_key' => EU_API_KEY,
                'api_url' => EU_API_URL,
                'url' => EU_URL
                };

        Map<String, String> devConfig = new Map<String, String>{
                'api_key' => DEV_API_KEY,
                'api_url' => DEV_API_URL,
                'url' => DEV_URL
                };

        ENVIRONMENTS = new Map<String, Map<String, String>>{
                'US' => usConfig,
                'EU' => euConfig,
                'DEV' => devConfig
                };
    }

    public HLEnvironment(String environment) {
        Map<String,String> e = ENVIRONMENTS.get(environment);
        if (e != null) {
            this.api_key = e.get('api_key');
            this.api_url = e.get('api_url');
            this.url = e.get('url');
        }
    }
}
