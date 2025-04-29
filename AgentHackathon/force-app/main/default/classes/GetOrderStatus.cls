public class GetOrderStatus {
    public static String getOrderResourceUrl(String orderNumber) {
        String endpoint = 'callout:CareLinkInternal/services/apexrest/orderlookup?orderNumber=' + EncodingUtil.urlEncode(orderNumber, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug('OrderSync Response: ' + res.getBody());

            return (String) body.get('Status');
        } else {
            return 'Error: ' + res.getBody();
        }
    }
}