public class  GetOrderStatusAction {
    public class InputWrapper {
        @InvocableVariable(required=true)
        public String orderNumber;
    }

    public class OutputWrapper {
        @InvocableVariable
        public String status;
    }

    @InvocableMethod(label='Get Order Status' description='Fetch the order status using the order number')
    public static List<OutputWrapper> getOrderStatus(List<InputWrapper> inputList) {
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper input : inputList) {
            OutputWrapper output = new OutputWrapper();

            try {
                String endpoint = 'callout:CareLinkInternal/services/apexrest/orderlookup?orderNumber=' +
                    EncodingUtil.urlEncode(input.orderNumber, 'UTF-8');

                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                req.setHeader('Accept', 'application/json');

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {
                    Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    output.status = (String) body.get('Status');
                } else {
                    output.status = 'Error: ' + res.getBody();
                }
            } catch (Exception ex) {
                output.status = 'Exception: ' + ex.getMessage();
            }

            results.add(output);
        }

        return results;
    }
}