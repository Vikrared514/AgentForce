@RestResource(urlMapping='/orderlookup/*')
global with sharing class OrderLookupService {
    
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String orderNumber = req.params.get('orderNumber');
        if (String.isBlank(orderNumber)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Missing orderNumber parameter');
            return;
        }

        List<Order> orders = [
            SELECT Id, OrderNumber,Status
            FROM Order
            WHERE OrderNumber = :orderNumber
            LIMIT 1
        ];

        if (orders.isEmpty()) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('Order not found');
        } else {
            
            Map<String, Object> response = new Map<String, Object>{
                'orderNumber' => orderNumber,
                'recordId' => orders[0].Id,
                'Status' => orders[0].status
            };
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
        }
    }
}