global class RestrictUnauthorizedAPIAcEventCondition implements TxnSecurity.EventCondition {

    public boolean evaluate(SObject event) {
        switch on event{
            when ApiEvent apiEvent {
                return evaluate(apiEvent);
            }
            when else{
                return false;
            }
        }
    }
    
    private boolean evaluate(ApiEvent event) {
        // Fetch the user ID
        Id userId = event.UserId;
        List<User> lstuser = [SELECT Id,Profile.UserLicense.name,UserType FROM User WHERE Id = :userId LIMIT 1];

        if ((lstuser==null) || (lstuser !=null && lstuser.size()==0) || (lstuser !=null && lstuser.size()>0 && (lstuser[0].Profile.UserLicense.name == 'Guest User License' || lstuser[0].UserType == 'Guest' ))) {
            // Block the transaction
            return true;
        }
        return false;
    }


}