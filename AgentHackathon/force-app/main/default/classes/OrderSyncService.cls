public class OrderSyncService {

    @future(callout=true)
    public static void sendOrderToOrgB(Id orderId) {
        try {
            Order ord = [
                SELECT Id, Name, Status, AccountId,
                       Account.Name, Account.Phone,EffectiveDate,
                       (SELECT Id,Product2.Name, Quantity, UnitPrice, PricebookEntryId FROM OrderItems)
                FROM Order
                WHERE Id = :orderId
                LIMIT 1
            ];
            System.debug('ord:>>.'+ord);
            Map<String, Object> payload = new Map<String, Object>{
                'account' => new Map<String, Object>{
                    'Name' => ord.Account != null ? ord.Account.Name : null,
                    'Phone' => ord.Account != null ? ord.Account.Phone : null
                },
                'order' => new Map<String, Object>{
                    'Name' => ord.Name,
                    'Status' => ord.Status,
                    'EffectiveDate' => ord.EffectiveDate
                     
                },
                'orderItems' => new List<Map<String, Object>>()
            };
         
            if (ord.OrderItems != null) {
                for (OrderItem oi : ord.OrderItems) {
                    ((List<Map<String, Object>>) payload.get('orderItems')).add(new Map<String, Object>{
                        'ProductName' => oi.Product2.Name,
                        'Quantity' => oi.Quantity,
                        'UnitPrice' => oi.UnitPrice,
                        'PricebookEntryId' => oi.PricebookEntryId
                    });
                }
            }
            system.debug(payload);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:CareLinkInternal/services/apexrest/syncOrder/');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('OrderSync Response: ' + res.getBody());
        } catch (Exception e) {
            System.debug('OrderSync Exception: ' + e.getMessage());
        }
    }
}