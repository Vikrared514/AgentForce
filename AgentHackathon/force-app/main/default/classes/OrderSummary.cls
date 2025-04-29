public class OrderSummary {
    
    public class orderSummaryOutput
    {
        @InvocableVariable(label = 'Order')
        public Order orderDetails;
        @InvocableVariable(label = 'Order Items')
        public List<OrderItem> orderItems;
        @InvocableVariable(label = 'Products')
        public List<Product2> products;
        @InvocableVariable(label = 'order summary status')
        public String processStatus;
    }
    
    @InvocableMethod (label='' description='')
    public static List<orderSummaryOutput> getOrderSummary( List<Id> orderIds)
    {
        List<orderSummaryOutput> output = new  List<orderSummaryOutput>();
        orderSummaryOutput result = new orderSummaryOutput();
        
        try
        {
            
            result.orderDetails = [Select Id, Name, OrderNumber From Order where Id = :orderIds[0]];
            result.orderItems = [Select Id, OrderItemNumber, Quantity, UnitPrice,Product2Id From OrderItem where orderId = :orderIds[0]];
            List<Id> productIds = new List<Id>();
            for(OrderItem item: result.orderItems)
            {
                productIds.add(item.Product2Id);
            }
            result.products = [Select Id, Name From Product2 where Id in :productIds];
             output.add(result);
        }
        catch(Exception Ex)
        {
            result.processStatus = 'Exception type caught: ' + ex.getTypeName()+'  Message: ' + ex.getMessage()+'  Cause: ' + ex.getCause() +'  Stack trace: ' + ex.getStackTraceString();
        	
            System.debug('Exception Type: ' + ex.getTypeName());
            System.debug('Exception Message: ' + ex.getMessage());
            System.debug('Exception Cause: ' + ex.getCause());
            System.debug('Exception Stack Trace: ' + ex.getStackTraceString());
        }
       
        return output;
    }
 
}