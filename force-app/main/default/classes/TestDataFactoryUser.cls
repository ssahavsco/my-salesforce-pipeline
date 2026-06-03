/***************************************************************
Interface Name : TestDataFactoryUser
CreatedDate : 10-Mar-20
*? Description : The purpose of this utility class to create the test Users
* Created By : Sumit Saha

*Revision History

Date Name Story Number Description
* 16-Mar-21 - OCOM-7851  - Develop the process of dormant users
***************************************************************/

@isTest 
public class TestDataFactoryUser {
    
  /**
   *? @description TestDataFactoryUser - this class is only for creating the users inserts
   * @author Sumit Saha
   * @param  onOfUser onOfUser is number of users to be created
   * @return          return the list of users created 
   */

  public static List<User> createUser(Integer onOfUser ){
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        List<User> usr = new List<User>();
            
            for(Integer counter=0; counter<onOfUser ;counter++){
                User u = new User();
                u.Alias = 'alias'; 
                u.Email='TestUser@lb.com';
                u.EmailEncodingKey='UTF-8'; 
                u.LastName='TestLastName'; 
                u.LanguageLocaleKey='en_US';
                u.LocaleSidKey='en_US'; 
                u.ProfileId = profile.Id;
                u.TimeZoneSidKey='America/Los_Angeles';
                u.UserName= counter +'@'+UserInfo.getOrganizationid()+'.test';
                usr.add(u);
            }
        
            Insert usr; 
      
            System.debug( 'Number of User Created: '+ usr.size());
           
           return usr;
           
    }

    public static List<Account> createAccount(Integer noOfAccounts, boolean doInsert, string recordTypeName ){
        
                    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

         List<Account> acc = new List<Account>();
            
            for(Integer counter=0; counter<noOfAccounts ;counter++){
                Account a = new Account();
                        a.firstName = 'TestPhone'+counter;
                        a.lastName = 'LastPhone1';
                        a.recordTypeId =recordTypeId; 
                        a.phone = '777888666'+counter;
                 acc.add(a);
            }
        
        If(doInsert){
            Insert acc; 
        }
      return acc;
           
    }
   
}