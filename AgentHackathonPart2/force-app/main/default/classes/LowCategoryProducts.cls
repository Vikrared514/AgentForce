@RestResource(urlMapping='/lowQuantityProducts')
global with sharing class LowCategoryProducts {
    @HttpGet
    global static List<Product2> getLowQuantityProducts() {
        RestRequest req = RestContext.request;
        List<Product2> lowQtyProducts = [
            SELECT Id, Name,Available_Quantity__c 
            FROM Product2
            WHERE Available_Quantity__c < 200
        ];

        return lowQtyProducts;
    }

    
}