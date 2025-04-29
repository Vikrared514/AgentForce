@RestResource(urlMapping='/OrderSummaryAPI/*')
global with sharing class OrderSummaryAPI {

    // Input Structure
    global class OrderSummaryInput {
        public List<Id> orderIds;
    }

    // DTO for Product
    global class ProductDTO {
        public Id id;
        public String name;
    }

    // DTO for Order Item
    global class OrderItemDTO {
        public Id id;
        public String orderItemNumber;
        public Decimal quantity;
        public Decimal unitPrice;
        public Id product2Id;
    }

    // DTO for Order
    global class OrderDTO {
        public Id id;
        public String name;
        public String orderNumber;
    }

    // Final Output Object
    global class OrderSummaryOutput {
        public OrderDTO orderDetails;
        public List<OrderItemDTO> orderItems;
        public List<ProductDTO> products;
        public String processStatus;
    }

    @HttpPost
    global static OrderSummaryOutput doPost() {
        RestRequest req = RestContext.request;
        OrderSummaryOutput result = new OrderSummaryOutput();

        try {
            OrderSummaryInput input = (OrderSummaryInput) JSON.deserialize(req.requestBody.toString(), OrderSummaryInput.class);

            if (input.orderIds == null || input.orderIds.isEmpty()) {
                result.processStatus = 'No Order IDs provided';
                return result;
            }

            Id orderId = input.orderIds[0];

            // Order
            Order order = [SELECT Id, Name, OrderNumber FROM Order WHERE Id = :orderId LIMIT 1];
            result.orderDetails = new OrderDTO();
            result.orderDetails.id = order.Id;
            result.orderDetails.name = order.Name;
            result.orderDetails.orderNumber = order.OrderNumber;

            // Order Items
            List<OrderItem> items = [SELECT Id, OrderItemNumber, Quantity, UnitPrice, Product2Id FROM OrderItem WHERE OrderId = :orderId];
            result.orderItems = new List<OrderItemDTO>();
            Set<Id> productIds = new Set<Id>();

            for (OrderItem item : items) {
                OrderItemDTO itemDTO = new OrderItemDTO();
                itemDTO.id = item.Id;
                itemDTO.orderItemNumber = item.OrderItemNumber;
                itemDTO.quantity = item.Quantity;
                itemDTO.unitPrice = item.UnitPrice;
                itemDTO.product2Id = item.Product2Id;
                result.orderItems.add(itemDTO);

                if (item.Product2Id != null) {
                    productIds.add(item.Product2Id);
                }
            }

            // Products
            result.products = new List<ProductDTO>();
            if (!productIds.isEmpty()) {
                List<Product2> products = [SELECT Id, Name FROM Product2 WHERE Id IN :productIds];
                for (Product2 prod : products) {
                    ProductDTO prodDTO = new ProductDTO();
                    prodDTO.id = prod.Id;
                    prodDTO.name = prod.Name;
                    result.products.add(prodDTO);
                }
            }

            result.processStatus = 'Success';

        } catch (Exception ex) {
            result.processStatus = 'Exception: ' + ex.getMessage();
        }

        return result;
    }
}