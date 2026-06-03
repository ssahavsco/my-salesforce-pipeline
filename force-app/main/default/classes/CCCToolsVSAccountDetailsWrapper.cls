/*
***********************************************************************************************************
* Program Name      : CCCToolsVSAccountDetailsWrapper
* Description       : Wrapper class to Store the response
* Version           : 1.1
* Modification Log  : 26-05-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-37149    1.1         Ravikant Kedia      13-05-2021      Created Wrapper class to store the data.
* REQ_02            DP-37149    1.2         Ravikant Kedia      26-05-2021      code commenting.
***********************************************************************************************************
*/
public class CCCToolsVSAccountDetailsWrapper {
    
    public ResponseCustomerProfile customerProfile;

	public class ResponseCustomerProfile {
		public String email;
		public String customerId;
		public ResponseCustPrefCC custPrefCC;
		public ResponseAddress address;
		public ResponseOnlineHistory onlineHistory;
	}

	public class ResponseCustPrefCC {
		public String ccType;
		public String ccLastFour;
		public String ccExpiry;
	}

	public class ResponseAddress {
		public String addressName;
		public String streetAddress1;
		public String city;
		public String state;
		public String countryCode;
		public String postalCode;
		public String phone;
	}

	public class ResponseOnlineHistory {
		public String sid;
		public String availableLoginAttempts;
		public String failedLoginAttempts;
		public String passwordResetLinkExpireDate;
		public String lastFailedLoginDate;
		public String lastSuccessfulLoginDate;
		public String dateAccountLastUpdated;
		public String createdAccountDate;
	}

    public List<ResponseLineItem> lineItem;

	public class ResponseLineItem {
		public String variantId;
		public String colorCode;
		public String sizeCode;
		public String adjustedPrice;
		public String origPrice;
		public String salesPrice;
		public String qty;
	}
}