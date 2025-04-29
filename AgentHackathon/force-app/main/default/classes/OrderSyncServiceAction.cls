public class OrderSyncServiceAction {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public Id orderId;
    }

    public class OutputWrapper {
        @InvocableVariable
        public String statusMessage;

        @InvocableVariable
        public String responseBody;

        @InvocableVariable
        public String errorMessage;
    }

    @InvocableMethod(label='Sync Order to Org B' description='Sends Order details to external Org B via callout')
    public static List<OutputWrapper> sendOrderToOrgB(List<InputWrapper> inputs) {
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper input : inputs) {
            OutputWrapper output = new OutputWrapper();

            try {
                Order ord = [
                    SELECT Id, Name, Status, AccountId,
                           Account.Name, Account.Phone, EffectiveDate,
                           (SELECT Id, Quantity, UnitPrice, PricebookEntryId FROM OrderItems)
                    FROM Order
                    WHERE Id = :input.orderId
                    LIMIT 1
                ];

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
                            'Quantity' => oi.Quantity,
                            'UnitPrice' => oi.UnitPrice,
                            'PricebookEntryId' => oi.PricebookEntryId
                        });
                    }
                }

                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:CareLinkInternal/services/apexrest/syncOrder/');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(payload));

                Http http = new Http();
                HttpResponse res = http.send(req);

                output.statusMessage = 'Success';
                output.responseBody = res.getBody();

            } catch (Exception e) {
                output.statusMessage = 'Failed';
                output.errorMessage = e.getMessage();
            }

            results.add(output);
        }

        return results;
    }
}