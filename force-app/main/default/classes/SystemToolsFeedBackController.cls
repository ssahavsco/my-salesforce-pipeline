/**
* @File Name : SystemToolsFeedBackController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : August 27, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 27, 2024 |   | Initial Version
**/

public class SystemToolsFeedBackController {
    @AuraEnabled
    public static List<Knowledge__kav> searchKnowledgeArticles(String searchString) {
        String query = 'SELECT Id, Title, UrlName, Summary, LastPublishedDate,External_URL__c, Internal_URL__c ' +
                        'FROM Knowledge__kav ' +
                        'WHERE PublishStatus = \'Online\' ' +
                        'AND (Title LIKE \'%' + searchString + '%\' ' +
                        'OR Summary LIKE \'%' + searchString + '%\') ';
        return Database.query(query);
    }
}