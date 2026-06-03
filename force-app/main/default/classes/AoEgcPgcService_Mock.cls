/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Mock class for AoEgcPgcService.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @modifiedBy     Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @maintainedBy   Ravikant Kedia  <ravikant.kedia@neuraflash.com>
* @version        1.0
* @created        2021-04-22
* @modified       2021-04-26
* @systemLayer    Test class
* @see            ????
* @see            ????
* @Jira Number    DP-37135, DP-37137
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global class AoEgcPgcService_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond( HTTPRequest request ) {
        
        HttpResponse res = new HttpResponse();
        res.setBody( '{"messageID":"230448513013"}' );
        if( request.getBody().contains( 'RT_POR' ) ){
            res.setStatusCode( 200 );
        } else {
            res.setStatusCode( 403 );
        }
        return res;
    }
}