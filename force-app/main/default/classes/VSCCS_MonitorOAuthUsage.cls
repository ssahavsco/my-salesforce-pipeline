/*
─────────────────────────────────────────────────────────────────────────────────────────────────
Apex Class Name    : VSCCS_MonitorOAuthUsage
Created Date       : Aug 12, 2025
@description       : This Class will get the OAuth records created by non-admin users and send email alert
@author            : Himanshu Mishra <hmishra@victoria.com>
@story             : 
Modification Log:
Ver   Date          Author          Story/Defect#         Modification
1.0   Aug 12, 2025  Himanshu Mishra   NA               	  Initial Version
─────────────────────────────────────────────────────────────────────────────────────────────────
*/
global class VSCCS_MonitorOAuthUsage implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        Integer last_N_Minutes = Integer.valueOf(System.Label.VSCCS_Last_N_Minutes);
        Datetime thirtyMinsAgo = Datetime.now().addMinutes(-last_N_Minutes);  // last 30 mins
		List<String> excludedProfiles = System.Label.Excluded_Profiles.split(','); //escluded profile e.g. System Admin, Analytics Integration
        
        List<OAuthToken> tokens = [
            SELECT Id, UserId, CreatedDate, User.Name, User.Profile.Name
            FROM OAuthToken
            WHERE CreatedDate >= :thirtyMinsAgo
            AND User.Profile.Name NOT IN :excludedProfiles
        ];

        sendEmail(tokens);
    }

    private void sendEmail(List<OAuthToken> tokens) {
        List<String> toAddress = Label.TechAlert.split(';');
        String subject = 'Non-Admin OAuthTokens Created in Last 30 Minutes';
        String body = '<p>Hi Team,</p>';
        body += '<p>The following OAuthToken records were created in the last 30 minutes by non-admin users:</p>';
        
		body += '<table border="1" cellpadding="5" cellspacing="0">';
        body += '<tr><th>OAuth Token Id</th><th>User Id</th><th>User Name</th><th>Profile Name</th><th>Created Date</th></tr>';
        if(tokens != null && tokens.size() > 0){
            for (OAuthToken token : tokens) {
                body += '<tr><td>' + token.Id + '</td><td>' + token.UserId + '</td><td>' + token.User.Name + '</td><td>' + token.User.Profile.Name + '</td><td>' + token.CreatedDate.format() + '</td></tr>';
            }
        }
        
        body += '</table>';
        body += '<p>Thanks & Regards,<br>Salesforce Team </p>';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddress);
        mail.setSubject(subject);
        mail.setHtmlBody(body);

        if(tokens != null && tokens.size() > 0) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}