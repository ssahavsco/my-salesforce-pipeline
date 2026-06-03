/**
 * @File Name : SuggestionBoxController.cls
 * @Description : Controller to fetch user mappings based on topic metadata.
 * @Author : Pooja
 * @Last Modified By :
 * @Last Modified On : April 2, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | April 2, 2025 |   | Initial Version
 **/

public with sharing class SuggestionBoxController {
  /**
   * @description Fetches user mappings (Primary and Secondary Owners) based on the topic.
   * @param topic The topic name to fetch user mappings for.
   * @return A map containing user IDs for active primary and secondary owners.
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getUserMapping(String topic) {
    // Query the custom metadata for user mapping
    Build_Our_Brand_Topic_Mapping__mdt metadata = [
      SELECT Primary_Owner__c, Secondary_Owner__c
      FROM Build_Our_Brand_Topic_Mapping__mdt
      WHERE Topic__c = :topic
      LIMIT 1
    ];

    // Initialize the map to store user mappings
    Map<String, String> userMapping = new Map<String, String>();

    // Add active primary owner to the map
    addActiveUserToMap(metadata.Primary_Owner__c, 'user1Id', userMapping);

    // Add active secondary owner to the map
    addActiveUserToMap(metadata.Secondary_Owner__c, 'user2Id', userMapping);

    return userMapping;
  }

  /**
   * @description Helper method to add an active user to the map.
   * @param userId The ID of the user to check.
   * @param key The key to use in the map for this user.
   * @param userMapping The map to store the user ID if the user is active.
   */
  private static void addActiveUserToMap(
    Id userId,
    String key,
    Map<String, String> userMapping
  ) {
    if (userId != null) {
      // Query the user record to check if the user is active
      User user = [
        SELECT Id, IsActive
        FROM User
        WHERE Id = :userId
        LIMIT 1
      ];
      if (user.IsActive) {
        userMapping.put(key, user.Id);
      }
    }
  }
}