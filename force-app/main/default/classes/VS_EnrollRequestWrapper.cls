public with sharing class VS_EnrollRequestWrapper {
    public VS_EnrollRequestWrapper(String brand, String email, String firstName, String lastName, String phone, String sourceCode, String sourceLocationCode, String sourceChannelCode, String customerType) {
        this.customer = new Customer(brand, email, firstName, lastName, phone);
        this.enrollInfo = new EnrollInfo(sourceCode, sourceLocationCode, sourceChannelCode, customerType);
    }
    public class Customer {
        public String brand;
        public String email;
        public String firstName;
        public String lastName;
        public String phone;
        public Customer(String brand, String email, String firstName, String lastName, String phone) {
            this.brand = brand;
            this.email = email;
            this.firstName = firstName;
            this.lastName = lastName;
            this.phone = phone;
        }
    }
    public class EnrollInfo {
        public String sourceCode;
        public String sourceLocationCode;
        public String sourceChannelCode;
        public String customerType;
    
        public EnrollInfo(String sourceCode, String sourceLocationCode, String sourceChannelCode, String customerType) {
            this.sourceCode = sourceCode;
            this.sourceLocationCode = sourceLocationCode;
            this.sourceChannelCode = sourceChannelCode;
            this.customerType = customerType;
        }
    }
    public Customer customer;
    public EnrollInfo enrollInfo;
}