public class FetchLowQuantity {
    public static String getExternalData() {
        String endpoint = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Use Named Credential URL
        request.setEndpoint('callout:My_Named_Credential/some/endpoint');
        request.setMethod('GET');
 
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                System.debug('Error: ' + response.getStatus());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception during callout: ' + e.getMessage());
            return null;
        }
    }
}