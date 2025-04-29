public class LowQuantityServiceFlow {

    public class OutputWrapper {
        @InvocableVariable
        public String statusMessage;

        @InvocableVariable
        public String responseBody;

        @InvocableVariable
        public String errorMessage;
    }

    @InvocableMethod(label='Fetch Low Quantity Products' description='Fetches low quantity products from Org B via callout')
    public static List<OutputWrapper> fetchLowQuantityProducts(List<String> dummyInput) {
        List<OutputWrapper> results = new List<OutputWrapper>();
        OutputWrapper output = new OutputWrapper();

        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CareLinkInternal/services/apexrest/lowQuantityProducts');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                output.statusMessage = 'Success';
                output.responseBody = response.getBody();
            } else {
                output.statusMessage = 'Failed';
                output.responseBody = response.getBody();
            }

        } catch (Exception e) {
            output.statusMessage = 'Error';
            output.errorMessage = e.getMessage();
        }

        results.add(output);
        return results;
    }
}