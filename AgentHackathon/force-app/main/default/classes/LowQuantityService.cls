public class LowQuantityService {

    @future(callout=true)
    public static void fetchLowQuantityProducts() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            // Named credential must point to the org hosting the REST resource
            request.setEndpoint('callout:CareLinkInternal/services/apexrest/lowQuantityProducts');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                System.debug('Low Quantity Products: ' + responseBody);
                
                // Optional: parse and use the response
                List<Product2> products = (List<Product2>) JSON.deserialize(responseBody, List<Product2>.class);
                System.debug(products);
            } else {
                System.debug('Callout failed. Status code: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception during callout: ' + e.getMessage());
        }
    }
}