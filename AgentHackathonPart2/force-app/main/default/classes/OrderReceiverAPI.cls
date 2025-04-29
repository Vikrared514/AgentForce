@RestResource(urlMapping='/syncOrder/')
global with sharing class OrderReceiverAPI {

    @HttpPost
    global static String receiveOrderData() {
        try {
            RestRequest req = RestContext.request;
            String body = req.requestBody.toString();

            // Parse the payload
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
            Map<String, Object> accData = (Map<String, Object>) payload.get('account');
            Map<String, Object> orderData = (Map<String, Object>) payload.get('order');

            // Safely convert order items
            List<Object> rawItems = (List<Object>) payload.get('orderItems');
            List<Map<String, Object>> items = new List<Map<String, Object>>();
            for (Object raw : rawItems) {
                items.add((Map<String, Object>) raw);
            }

            // Handle Account creation or retrieval by Phone
            Account acc;
            String phone = (String) accData.get('Phone');

            List<Account> existingAccs = [
                SELECT Id, Name, Phone FROM Account WHERE Phone = :phone LIMIT 1
            ];

            if (!existingAccs.isEmpty()) {
                acc = existingAccs[0];
            } else {
                acc = new Account();
                acc.Name = (String) accData.get('Name');
                acc.Phone = (String) accData.get('Phone');
                insert acc;
            }

            // Create Order
            Order ord = new Order();
            ord.Description = (String) orderData.get('Name');
            ord.Status = (String) orderData.get('Status');
            ord.AccountId = acc.Id;
            String effDateStr = (String) orderData.get('EffectiveDate');
            if (effDateStr != null) {
                ord.EffectiveDate = Date.valueOf(effDateStr);
            }

            insert ord;

            // Create OrderItems
         /*   List<OrderItem> orderItems = new List<OrderItem>();
            for (Map<String, Object> item : items) {
                OrderItem oi = new OrderItem();
                oi.OrderId = ord.Id;
                oi.product2 =(String) ord.ProductName;
                oi.Quantity = (Decimal) item.get('Quantity');
                oi.UnitPrice = (Decimal) item.get('UnitPrice');
              //  oi.PricebookEntryId = (String) item.get('PricebookEntryId');
                orderItems.add(oi);
            }
            insert orderItems;*/

            // Set success response
            RestContext.response.statusCode = 200;
            return JSON.serialize(new Map<String, Object>{
                'success' => true,
                'message' => 'Order synced successfully.',
                'accountId' => acc.Id,
                'orderId' => ord.Id
            });

        } catch (Exception ex) {
            // Set error response
            RestContext.response.statusCode = 500;
            return JSON.serialize(new Map<String, Object>{
                'success' => false,
                'error' => ex.getMessage()
            });
        }
    }
}