@isTest
public class PHISTorderTransactionWrapperTest {

    @isTest
    public static void testWrapperClasses() {
        // Test ResponseOrder
        PHISTorderTransactionWrapper.ResponseOrder responseOrder = new PHISTorderTransactionWrapper.ResponseOrder();
        responseOrder.OMS = 'OMS123';
        responseOrder.CapturedDate = '2024-12-11';
        responseOrder.CreatedTimestamp = '2024-12-11T00:00:00Z';
        responseOrder.BusinessDate = '2024-12-11';
        responseOrder.OrderTotal = 150.00;
        // responseOrder.formattedCurrency = 'USD';
        responseOrder.TotalTaxes = 10.00;
        responseOrder.OrderShipHandleAmount = 5.00;
        responseOrder.OrderId = 'ORD12345';
        responseOrder.SellingChannel = new PHISTorderTransactionWrapper.ResponseSellingChannel();
        responseOrder.OrderType = new PHISTorderTransactionWrapper.ResponseOrderType();
        responseOrder.CurrencyCode = 'USD';
        responseOrder.CustomerPhone = '1234567890';
        responseOrder.CustomerEmail = 'test@example.com';
        responseOrder.CustomerFirstName = 'John';
        responseOrder.CustomerLastName = 'Doe';
        responseOrder.CustomerId = 'CUST123';
        responseOrder.IsTaxExempt = false;
        responseOrder.IsCancelled = false;
        responseOrder.Payment = new List<PHISTorderTransactionWrapper.ResponsePayment>();
        responseOrder.OrderChargeDetail = new List<PHISTorderTransactionWrapper.ResponseOrderChargeDetail>();
        responseOrder.OrderExtension3 = new List<PHISTorderTransactionWrapper.ResponseOrderExtension3>();
        responseOrder.OrderLine = new List<PHISTorderTransactionWrapper.ResponseOrderLine>();
        responseOrder.Extended = new PHISTorderTransactionWrapper.ResponseExtended();
        responseOrder.Invoice = new List<PHISTorderTransactionWrapper.ResponseInvoice>();
        responseOrder.MinFulfillmentStatusId = '1';
        responseOrder.MaxFulfillmentStatusId = '2';
        responseOrder.MaxReturnStatusId = '3';
        responseOrder.OrderSubTotal = 140.00;
        responseOrder.UpdatedTimeStamp = '2024-12-11T01:00:00Z';
        responseOrder.mfGiftWrapAmount = 2.50;
        responseOrder.ExtendedLegacyOrder = new PHISTorderTransactionWrapper.ResonseExtendedLegacyOrder();
        responseOrder.ShopperPayment = new PHISTorderTransactionWrapper.ResponseShopperPayment();
        responseOrder.status = 'Pending';
        responseOrder.LoyaltyNumber = 'LOY12345';
        responseOrder.OrderNote = new List<PHISTorderTransactionWrapper.OrderNote>();
        responseOrder.ReturnTrackingDetail = new List<PHISTorderTransactionWrapper.ResponseReturnTrackingDetail>();

        // Assert the basic properties
        System.assertEquals('OMS123', responseOrder.OMS);
        System.assertEquals('ORD12345', responseOrder.OrderId);
        System.assertEquals(150.00, responseOrder.OrderTotal);
        
        // Test OrderNote
        PHISTorderTransactionWrapper.OrderNote orderNote = new PHISTorderTransactionWrapper.OrderNote();
        orderNote.NoteId = 'NOTE123';
        orderNote.UpdatedTimestamp = '2024-12-11T01:00:00Z';
        orderNote.CreatedBy = 'Admin';
        orderNote.CreatedTimestamp = '2024-12-11T00:00:00Z';
        orderNote.DisplaySequence = 1;
        orderNote.NoteText = 'This is a test note.';
        orderNote.OrgId = 'ORG123';
        orderNote.UpdatedBy = 'Admin';
        orderNote.NoteType = new PHISTorderTransactionWrapper.NoteType();
        orderNote.NoteCategory = new PHISTorderTransactionWrapper.NoteCategory();
        orderNote.IsVisible = true;
        
        // Assert OrderNote properties
        System.assertEquals('NOTE123', orderNote.NoteId);
        System.assertEquals('This is a test note.', orderNote.NoteText);
        System.assert(orderNote.IsVisible);
        
        // Test nested classes in ResponsePayment
        PHISTorderTransactionWrapper.ResponsePayment payment = new PHISTorderTransactionWrapper.ResponsePayment();
        payment.PaymentMethod = new List<PHISTorderTransactionWrapper.ResponsePaymentMethod>();
        PHISTorderTransactionWrapper.ResponsePaymentMethod paymentMethod = new PHISTorderTransactionWrapper.ResponsePaymentMethod();
        paymentMethod.AccountDisplayNumber = '****1234';
        paymentMethod.Amount = 150.00;
        paymentMethod.CardType = new PHISTorderTransactionWrapper.ResponseCardType();
        paymentMethod.CardTypeId = 'Visa';
        payment.PaymentMethod.add(paymentMethod);
        responseOrder.Payment.add(payment);

        // Assert payment details
        System.assertEquals(1, responseOrder.Payment.size());
        System.assertEquals('****1234', responseOrder.Payment[0].PaymentMethod[0].AccountDisplayNumber);
        
        // Test ResponseOrderLine
        PHISTorderTransactionWrapper.ResponseOrderLine orderLine = new PHISTorderTransactionWrapper.ResponseOrderLine();
        orderLine.OrderId = 'ORD12345';
        orderLine.ItemDescription = 'Test Item';
        orderLine.Quantity = 1;
        orderLine.OrderLineSubTotal = 50.00;
        orderLine.UnitPrice = 50.00;
        orderLine.Sku = new PHISTorderTransactionWrapper.ResponseSKU();
        responseOrder.OrderLine.add(orderLine);
        
        // Assert order line details
        System.assertEquals('ORD12345', responseOrder.OrderLine[0].OrderId);
        System.assertEquals('Test Item', responseOrder.OrderLine[0].ItemDescription);
        System.assertEquals(50.00, responseOrder.OrderLine[0].OrderLineSubTotal);
    }
}