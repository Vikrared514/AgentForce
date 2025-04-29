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
            
            // Using the Named Credential
            request.setEndpoint('https://api.salesforce.com/einstein/ai-agent/v1/agents/0XxKB000000LLN30AO/sessions');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer '+getAccessToken()); // Add your actual access token here
            request.setMethod('POST');

            // Optional headers
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                system.debug('response=='+response.getBody());
                return response.getBody();
            } else {
                throw new CalloutException('Failed with status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Callout Error: ' + e.getMessage());
            return null;
        }
    }
}