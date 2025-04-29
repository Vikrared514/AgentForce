public class AgentForceController {
    
        // Hardcoded credentials and token URL
    private static final String CLIENT_ID = '3MVG9uq9ANVdsbAWPzOJVxf89m4NlFF2cvgBouYdak9MvJ_k9ftCpBsS7lUSzgRB3XSDEbKhZYu9hqzQ6E3MA';
    private static final String CLIENT_SECRET = '37897F4C88EDE85C0743104B97981288972F3FD500EC11DA2E27EAF60B574C77';
    private static final String TOKEN_URL = 'https://orgfarm-9a314bd076-dev-ed.develop.my.salesforce.com/services/oauth2/token';

    public class AccessTokenResponse {
        public String access_token;
        public String token_type;
        public Integer expires_in;
    }

    /**
     * Retrieves access token using hardcoded client credentials
     */
    @AuraEnabled
    public static String getAccessToken() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(TOKEN_URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=client_credentials' +
                      '&client_id=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') +
                      '&client_secret=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8');

        request.setBody(body);

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                AccessTokenResponse tokenResponse = (AccessTokenResponse) JSON.deserialize(response.getBody(), AccessTokenResponse.class);
                return tokenResponse.access_token;
            } else {
                System.debug('Error getting token: ' + response.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }

@AuraEnabled
public static String getApiResponse() {
    try {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String agentId = '0XxKB000000LLN30AO'; // Replace with your actual Einstein Agent ID
        String myDomain = 'orgfarm-9a314bd076-dev-ed.develop.my.salesforce.com'; // Replace with your domain

        String endpointUrl = 'https://api.salesforce.com/einstein/ai-agent/v1/agents/' + agentId + '/sessions';
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken());

        // Generate a pseudo UUID for externalSessionKey
        String uuid = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(Datetime.now().getTime())))).substring(0, 32);

        Map<String, Object> body = new Map<String, Object>();
        body.put('externalSessionKey', uuid);

        Map<String, Object> instanceConfig = new Map<String, Object>();
        instanceConfig.put('endpoint', 'https://' + myDomain);
        body.put('instanceConfig', instanceConfig);

        Map<String, Object> streamingCapabilities = new Map<String, Object>();
        streamingCapabilities.put('chunkTypes', new List<String>{'Text'});
        body.put('streamingCapabilities', streamingCapabilities);

        body.put('bypassUser', true);

        request.setBody(JSON.serialize(body));

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            // Parse JSON and extract sessionId
            Map<String, Object> fullResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String sessionId = (String) fullResponse.get('sessionId');
            return sessionId;
        } else {
            System.debug('Status: ' + response.getStatus());
            System.debug('Body: ' + response.getBody());
            throw new CalloutException('Failed with status code: ' + response.getStatusCode());
        }
    } catch (Exception e) {
        System.debug('Callout Error: ' + e.getMessage());
        return null;
    }
}

@AuraEnabled
    public static void endSession(){
        
        try {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        Long sequenceId = DateTime.now().getTime();       
        string sessionId = getApiResponse();
        String endpoint = 'https://api.salesforce.com/einstein/ai-agent/v1/sessions/' + sessionId;
        request.setEndpoint(endpoint);
        request.setMethod('DELETE');

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken());
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug('Message Response: ' + response.getBody());
        } else {
            System.debug('Error Response: ' + response.getBody());
            throw new CalloutException('Failed with status code: ' + response.getStatusCode());
        }

    } catch (Exception e) {
        System.debug('Callout Exception: ' + e.getMessage());
    }
    } 
    
@AuraEnabled
public static String agentForceApi(String messageText) {
    try {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        Long sequenceId = DateTime.now().getTime();       
        string sessionId = getApiResponse();
        String endpoint = 'https://api.salesforce.com/einstein/ai-agent/v1/sessions/' + sessionId + '/messages';
        request.setEndpoint(endpoint);
        request.setMethod('POST');

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken());

        // Prepare body payload
        Map<String, Object> messagePayload = new Map<String, Object>{
            'sequenceId' => sequenceId,
            'type' => 'Text',
            'text' => messageText
        };

        Map<String, Object> requestBody = new Map<String, Object>{
            'message' => messagePayload
        };

        request.setBody(JSON.serialize(requestBody));

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug('Message Response: ' + response.getBody());
          
            return response.getBody();
        } else {
            System.debug('Error Response: ' + response.getBody());
            throw new CalloutException('Failed with status code: ' + response.getStatusCode());
        }

    } catch (Exception e) {
        System.debug('Callout Exception: ' + e.getMessage());
        return null;
    }
}


}