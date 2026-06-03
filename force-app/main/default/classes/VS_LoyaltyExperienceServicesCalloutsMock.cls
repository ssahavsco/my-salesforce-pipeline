@isTest
global with sharing class VS_LoyaltyExperienceServicesCalloutsMock implements HttpCalloutMock {
  private Integer stCode;
  private String srvcName;
  public VS_LoyaltyExperienceServicesCalloutsMock(
    Integer statusCode,
    String serviceName
  ) {
    stCode = statusCode;
    srvcName = serviceName;
  }
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new Httpresponse();
    if (stCode == 200 && srvcName == 'SUCCESS_POINTS_HISTORY') {
      response.setStatusCode(stCode);
      String responseJSON = '{"points":[{"description":"Appeasement","points":5,"transactionDate":1664299775},{"description":"Appeasement","points":30,"transactionDate":1664299733},{"description":"Appeasement","points":15,"transactionDate":1664299627},{"description":"Appeasement","points":10,"transactionDate":1664299576},{"description":"Appeasement","points":100,"transactionDate":1664299467},{"description":"Appeasement","points":1,"transactionDate":1663678363}]}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 200 && srvcName == 'SUCCESS_POINTS_BALANCE') {
      response.setStatusCode(stCode);
      String responseJSON = '{"loyaltyId":"76107236053","tiers":{"currentTier":{"code":"VST3","description":"VIP"},"nextTier":{"amountRequired":0,"upgradeByDate":0}},"points":{"currentBalance":27,"requiredForNextReward":1973},"accrualRules":[{"accrualType":"SPEND","points":15,"amount":1},{"accrualType":"EARN_REWARDS","points":2000,"amount":10}],"currency":"USD","customerType":"VSCC"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 200 && srvcName == 'SUCCESS_POINTS_BALANCE_BOT') {
      response.setStatusCode(stCode);
      String responseJSON = '{"loyaltyId":"34988882994","tiers":{"spendByDate":1704067199,"currentTier":{"code":"VST3","description":"VIP","amountRequiredToMaintain":0},"nextTier":{"amountRequired":0}},"points":{"currentBalance":1151,"requiredForNextReward":849},"accrualRules":[{"accrualType":"SPEND","points":5,"amount":1},{"accrualType":"EARN_REWARDS","points":2000,"amount":10}],"rewards":[{"startDate":1681790400}],"currency":"USD","customerType":"NON-VSCC","communityId":"c6ae73d500564e2eb6d10864c11d9261d4e23541"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 401 && srvcName == 'SUCCESS_POINTS_BALANCE_BOT') {
      response.setStatusCode(stCode);
      String responseJSON = '{"loyaltyId":"34988882994","tiers":{"spendByDate":1704067199,"currentTier":{"code":"VST3","description":"VIP","amountRequiredToMaintain":0},"nextTier":{"amountRequired":0}},"points":{"currentBalance":1151,"requiredForNextReward":849},"accrualRules":[{"accrualType":"SPEND","points":5,"amount":1},{"accrualType":"EARN_REWARDS","points":2000,"amount":10}],"rewards":[{"startDate":1681790400}],"currency":"USD","customerType":"NON-VSCC","communityId":"c6ae73d500564e2eb6d10864c11d9261d4e23541"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 200 && srvcName == 'SUCCESS_CUSTOMER_REWARDS') {
      response.setStatusCode(stCode);
      String responseJSON = '{"rewards":[{"title":"$10 Member Reward","amount":"$10","prefix":"RVALOYCC10","code":"RVALOYCC10MEFXZ4T","startDate":1663632000,"endDate":1672963200,"currency":"USD","redeemed":false}],"offers":[]}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 200 && srvcName == 'SUCCESS_TRANSACTION_DETAILS') {
      response.setStatusCode(stCode);
      String responseJSON = '{"clientProperties":null,"error":{"errorMessage":"","errorCode":""},"payload":{"transaction":{"acctId":6014,"baseCurrencyCode":"USD","baseRewardsTotal":0,"bonusRewardsTotal":2563,"currencyCode":"USD","currencyDescription":"United States dollar","eligibleRevenue":255.92,"externalTransId":"C300046500_166314073829338888","locationCode":"","locationDescription":"","merchantCategoryCode":"","merchantCategoryDescription":"","merchantDescriptor":"","postDate":"2022-09-14T07:32:19.246+0000","rewardDescription":"Points","rewardType":"PT","rewards":[{"amount":"146","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10250,"rewardTypeId":"PT","tqvInd":false},{"amount":"96","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10251,"rewardTypeId":"PT","tqvInd":false},{"amount":"114","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10252,"rewardTypeId":"PT","tqvInd":false},{"amount":"228","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10255,"rewardTypeId":"PT","tqvInd":false},{"amount":"96","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10256,"rewardTypeId":"PT","tqvInd":false},{"amount":"542","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10257,"rewardTypeId":"PT","tqvInd":false},{"amount":"543","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10253,"rewardTypeId":"PT","tqvInd":false},{"amount":"228","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10259,"rewardTypeId":"PT","tqvInd":false},{"amount":"228","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10260,"rewardTypeId":"PT","tqvInd":false},{"amount":"114","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10254,"rewardTypeId":"PT","tqvInd":false},{"amount":"228","baseInd":false,"bonusCode":"VSCCT2BONUS","bonusDescription":"Tier 2 VSCC Cardholders will receive an additional 5 points/$ spent on eligible items","bonusType":"TXNBONUS","rewardDescription":"Points","rewardId":10258,"rewardTypeId":"PT","tqvInd":false}],"rewardsTotal":2563,"tax":0,"taxF":0,"transAmount":255.92,"transAmountF":255.92,"transCategoryCode":"ONLINE","transCategoryDescription":"Online","transEndDate":"2022-09-13T14:23:58.262+0000","transId":9163,"transStartDate":"2022-09-13T14:23:58.262+0000","transSubTypeCode":"","transSubTypeDescription":"","transTypeCode":"SALE","transTypeDescription":"Sale","transactionAttributes":null,"transactionDetails":[{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Lace-trim Cheekini Panty","detailRecordNumber":0,"eligibleRevenue":14.56,"excluded":false,"itemLineNum":1,"price":14.56,"pricePerItem":7.28,"productCode":"","productSku":"24555103","qty":2,"retailPrice":15.98,"retailPricePerItem":7.99,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":14.56,"transDetailId":9352,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Lace Trim No-Show Hipster","detailRecordNumber":0,"eligibleRevenue":9.56,"excluded":false,"itemLineNum":2,"price":9.56,"pricePerItem":9.56,"productCode":"","productSku":"26195276","qty":1,"retailPrice":10.5,"retailPricePerItem":10.5,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":9.56,"transDetailId":9353,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":11.38,"excluded":false,"itemLineNum":3,"price":11.38,"pricePerItem":11.38,"productCode":"","productSku":"23286075","qty":1,"retailPrice":24.99,"retailPricePerItem":24.99,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":11.38,"transDetailId":9354,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Light Push-up Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":54.21,"excluded":false,"itemLineNum":4,"price":54.21,"pricePerItem":54.21,"productCode":"","productSku":"26000470","qty":1,"retailPrice":59.5,"retailPricePerItem":59.5,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":54.21,"transDetailId":9355,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":11.38,"excluded":false,"itemLineNum":5,"price":11.38,"pricePerItem":11.38,"productCode":"","productSku":"23286075","qty":1,"retailPrice":24.99,"retailPricePerItem":24.99,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":11.38,"transDetailId":9356,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Light Push-up Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":22.76,"excluded":false,"itemLineNum":6,"price":22.76,"pricePerItem":22.76,"productCode":"","productSku":"24627536","qty":1,"retailPrice":24.99,"retailPricePerItem":24.99,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":22.76,"transDetailId":9357,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Lace Trim No-Show Hipster","detailRecordNumber":0,"eligibleRevenue":9.57,"excluded":false,"itemLineNum":7,"price":9.57,"pricePerItem":9.57,"productCode":"","productSku":"26195276","qty":1,"retailPrice":10.5,"retailPricePerItem":10.5,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":9.57,"transDetailId":9358,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Light Push-up Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":54.2,"excluded":false,"itemLineNum":8,"price":54.2,"pricePerItem":54.2,"productCode":"","productSku":"26000470","qty":1,"retailPrice":59.5,"retailPricePerItem":59.5,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":54.2,"transDetailId":9359,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":22.77,"excluded":false,"itemLineNum":9,"price":22.77,"pricePerItem":22.77,"productCode":"","productSku":"23286075","qty":1,"retailPrice":24.99,"retailPricePerItem":24.99,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":22.77,"transDetailId":9360,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Light Push-up Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":22.76,"excluded":false,"itemLineNum":10,"price":22.76,"pricePerItem":22.76,"productCode":"","productSku":"24627536","qty":1,"retailPrice":24.99,"retailPricePerItem":24.99,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":22.76,"transDetailId":9361,"transId":9163},{"acctId":6014,"currencyCode":"USD","customerId":4038,"description":"Light Push-up Perfect Shape Bra","detailRecordNumber":0,"eligibleRevenue":22.77,"excluded":false,"itemLineNum":11,"price":22.77,"pricePerItem":22.77,"productCode":"","productSku":"24627536","qty":1,"retailPrice":24.99,"retailPricePerItem":24.99,"status":"A","tax":0,"taxPerItem":0,"totalLineAmount":22.77,"transDetailId":9362,"transId":9163}],"transactionTenders":[{"cardLastFour":"","certNumber":"","currencyCode":"USD","exclude":false,"paymentAmount":255.92,"paymentDescription":"Victorias Secret Credit Card","paymentType":"VC","transTenderId":9094}],"xrefId":0}},"sessionId":"","version":"1"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 200 && srvcName == 'SUCCESS_ADD_POINTS') {
      response.setStatusCode(stCode);
      String responseJSON = '{"clientProperties":null,"error":{"errorMessage":"","errorCode":""},"payload":{"code":"","externalNode":{"additionalProp1":{},"additionalProp2":{},"additionalProp3":{}},"id":15049,"uuid":""},"sessionId":"","version":"1"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 400 && srvcName == 'FAILURE_POINTS_HISTORY') {
      response.setStatusCode(stCode);
      String responseJSON = '{"errorCode":401,"errorMessage":"Sorry. The information you are trying to access is unauthorized. Please sign in with a valid account. "}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 400 && srvcName == 'FAILURE_TRANSACTION_DETAILS') {
      response.setStatusCode(stCode);
      String responseJSON = '{"clientProperties":null,"error":{"errorMessage":"Sorry. The information you are trying to access is unauthorized","errorCode":"401"}}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 400 && srvcName == 'FAILURE_ADD_POINTS') {
      response.setStatusCode(stCode);
      String responseJSON = '{"clientProperties":null,"error":{"errorMessage":"Adjustment code [] does not exist","errorCode":"-2000"},"payload":{"code":"","externalNode":{"additionalProp1":{},"additionalProp2":{},"additionalProp3":{}},"id":0,"uuid":""},"sessionId":"","version":"1"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 200 && srvcName == 'SUCCESS_ENROLL') {
      response.setStatusCode(stCode);
      String responseJSON = '{"cgridId": "336e7172-d907-4a21-b9fb-0f6a0bf4b8e4", "vsLoyaltyId": "98655122887", "kobieUuid": "f3f12e97-b52b-4419-aa59-5fcb090e6bd0", "tierCode": "VST1","status": "P","statusReason": "AP"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 400 && srvcName == 'FAILURE_ENROLL') {
      response.setStatusCode(stCode);
      String responseJSON = '{"code": "400","message": "invalid email id or phone number"}';
      response.setBody(responseJSON);
      return response;
    } else if (stCode == 401 && srvcName == 'EXCEPTION_POINTS_HISTORY') {
      CalloutException e = (CalloutException) CalloutException.class
        .newInstance();
      e.setMessage(
        'This is a constructed exception for testing and code coverage'
      );
      throw e;
    } else if (stCode == 401 && srvcName == 'EXCEPTION_TRANSACTION_DETAILS') {
      CalloutException e = (CalloutException) CalloutException.class
        .newInstance();
      e.setMessage(
        'This is a constructed exception for testing and code coverage'
      );
      throw e;
    } else if (stCode == 401 && srvcName == 'EXCEPTION_ADD_POINTS') {
      CalloutException e = (CalloutException) CalloutException.class
        .newInstance();
      e.setMessage(
        'This is a constructed exception for testing and code coverage'
      );
      throw e;
    }

    return null;
  }
}