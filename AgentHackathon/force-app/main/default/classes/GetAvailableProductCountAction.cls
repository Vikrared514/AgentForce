public class GetAvailableProductCountAction {
    public class InputWrapper {
        @InvocableVariable(required=true)
        public String productName;

        @InvocableVariable(required=true)
        public String category;
    }

    public class OutputWrapper {
        @InvocableVariable
        public String inventoryResponse;
    }

    @InvocableMethod(label='Get Product Inventory Count' description='Get inventory info for a product and category')
    public static List<OutputWrapper> getProductInventoryCount(List<InputWrapper> inputList) {
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper input : inputList) {
            OutputWrapper output = new OutputWrapper();

            try {
                String endpoint = 'callout:CareLinkInternal/services/apexrest/AvailableProductCount/';
                String requestUrl = endpoint + '?productName=' + EncodingUtil.urlEncode(input.productName, 'UTF-8') +
                                    '&category=' + EncodingUtil.urlEncode(input.category, 'UTF-8');

                HttpRequest req = new HttpRequest();
                req.setEndpoint(requestUrl);
                req.setMethod('GET');
                req.setHeader('Accept', 'application/json');

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {
                    output.inventoryResponse = res.getBody(); // or parse it further if needed
                } else {
                    output.inventoryResponse = 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();
                }
            } catch (Exception ex) {
                output.inventoryResponse = 'Exception: ' + ex.getMessage();
            }

            results.add(output);
        }

        return results;
    }
}