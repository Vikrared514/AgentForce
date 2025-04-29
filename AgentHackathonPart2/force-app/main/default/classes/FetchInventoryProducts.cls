@RestResource(urlMapping='/AvailableProductCount/*')
global class FetchInventoryProducts {

    public class ProductResponse {
        public String Name;
        public String ProductCategory;
        public Decimal AvailableQuantity;

        public ProductResponse(String name, String category, Decimal quantity) {
            this.Name = name;
            this.ProductCategory = category;
            this.AvailableQuantity = quantity;
        }
    }

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

      /*  String productName = req.params.get('productName');
        String category = req.params.get('category');

        if (String.isBlank(productName)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Missing productName parameter');
            return;
        }
*/
        // Start building the query with the productName filter
        String query = 'SELECT Id, Name, Category__c, Available_Quantity__c FROM Product2 WHERE Available_Quantity__c < 200';

        // Add the category filter if it's provided
   /*     if (!String.isBlank(category)) {
            query += ' AND Category__c = :category';
        }*/

        // Execute the query
        List<Product2> products = Database.query(query);

        if (products.isEmpty()) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('Product not found');
        } else {
            List<ProductResponse> responseList = new List<ProductResponse>();
            
            // Loop through all products and create the response wrapper object for each product
            for (Product2 product : products) {
                ProductResponse productResponse = new ProductResponse(
                    product.Name, 
                    product.Category__c, 
                    product.Available_Quantity__c
                );
                responseList.add(productResponse);
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(responseList));
        }
    }
}