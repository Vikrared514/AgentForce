public class GetAvailableProductCount {

    public static String getProductInventory() {
        String requestUrl = 'callout:CareLinkInternal/services/apexrest/AvailableProductCount/';
        
        // Build the request URL with parameters
        /*String requestUrl = endpoint; + '?productName=' + EncodingUtil.urlEncode(productName, 'UTF-8') +
                            '&category=' + EncodingUtil.urlEncode(category, 'UTF-8');*/
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestUrl);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Deserialize the response body into a list of maps (products)
           // List<Map<String, Object>> products = (List<Map<String, Object>>)JSON.deserializeUntyped(res.getBody());
            system.debug(res.getBody());
            return res.getBody();//'Received ' + products.size() + ' products.';
        } else {
            return 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();
        }
    }
}