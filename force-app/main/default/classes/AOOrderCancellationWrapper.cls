/*
***********************************************************************************************************
* Program Name      : AOOrderCancellationWrapper
* Description       : Wrapper class to Store the response
* Version           : 1.1
* Modification Log  : 16-08-2021
*----------------------------------------------------------------------------------------------------------
* RequirementId     JiraId      Version     Developer           Date            Description
*----------------------------------------------------------------------------------------------------------
* REQ_01            DP-39921    1.1         Ravikant Kedia      13-05-2021      Created Wrapper class to store the data.
***********************************************************************************************************
*/
public class AOOrderCancellationWrapper {

	public Boolean success;
	public String header;
	public String data;
	public String messageKey;	//error.400
	public String message;	//error.400
	public List<ResponseErrors> errors;
	public List<ResponseExceptions> exceptions;
	public ResponseMessages messages;
	public String rootCause;	//java.lang.Throwable: Throwable with cause of type 'com.manh.cp.om.lib.omni.exception.OmniRuntimeException' was caught and handled by CustomErrorController (see logs for the trace)
	public String cloudComponent;	//com-manh-cp-order:order,docker,omni,rest,cloud,kubernetes,rest-kubernetes,lmit,s,lmits,lmitosf11o:8080
	public String cloudComponentHostName;	//com-manh-cp-order-868fc96c9f-8ln59
	public String requestUri;	///error
	public String statusCode;	//BAD_REQUEST
	
	class ResponseErrors { }

	class ResponseExceptions {
		public ResponseMessageData messageData;
		public String resource;	//Throwable
		public String messageKey;	//Throwable
		public String message;	//Throwable with cause of type 'com.manh.cp.om.lib.omni.exception.OmniRuntimeException' was caught and handled by CustomErrorController (see logs for the trace)
		public String stackTrace;	//java.lang.Throwable: Throwable with cause of type 'com.manh.cp.om.lib.omni.exception.OmniRuntimeException' was caught and handled by CustomErrorController (see logs for the trace)

	}

	class ResponseMessageData { }

	class ResponseMessages {
		public List<ResponseMessage> Message;
		public Integer Size;	//1
	}

	class ResponseMessage {
		public String Type;	//ERROR
		public String Code;	//ord::10007
		public String Description;	//Order is not allowed to perform the following modification for Status: Released, Mod Type: Order::Cancel, Order Id: W008087551.
		public String ShortDescription;
		public String ErrorCode;	//10007
		public String ErrorField;
		public String ResourceId;
		public Boolean QuickInfo;
		public String BusinessKeys;
	}
}