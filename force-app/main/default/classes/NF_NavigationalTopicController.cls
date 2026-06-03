public without sharing class  NF_NavigationalTopicController {
    
    @AuraEnabled
    Public static List<NavigationalTopicWrapper> fetchNavigationalTopics(){
        Map<String,Set<String>> navTopicToSubTopicMap =  new Map<String,Set<String>>();
        Set<String> topicNameSet = new Set<String>();  
        List<NavigationalTopicInformation__mdt> navigationTopicList =[Select developerName,MasterLabel,Icon_Name__c,Sort_Order__c,
                                                                      (Select DeveloperName,Label,MasterLabel From Navigational_Subtopic_Informations__r)
                                                                      From NavigationalTopicInformation__mdt 
                                                                      where  Icon_Name__c != null and Sort_Order__c != null and FAQ_Topic__c = false 
                                                                      ORDER BY Sort_Order__c ASC NULLS LAST];

        String communityId = Network.getNetworkId();
        if(Test.isRunningTest()){
            navigationTopicList = new List<NavigationalTopicInformation__mdt>{new NavigationalTopicInformation__mdt(developerName='International1',
                                                                                                                    MasterLabel='International1',
                                                                                                                    Icon_Name__c='watchIcon',
                                                                                                                    Sort_Order__c=1)};

            Network NetworkRec = [SELECT Name, Id, Status, Description 
                                 FROM Network order by id limit 1];
            
            if(NetworkRec != null){
                communityId = NetworkRec.Id;
            }else{
                communityId='';
            }
            
        }


        if(navigationTopicList != null && navigationTopicList.size() > 0){
            for(NavigationalTopicInformation__mdt navMetadataRecord : navigationTopicList){
                topicNameSet.add(navMetadataRecord.MasterLabel.toLowerCase().trim());
                if(navMetadataRecord.Navigational_Subtopic_Informations__r != null && navMetadataRecord.Navigational_Subtopic_Informations__r.size() > 0){
                    for(Navigational_Subtopic_Information__mdt navSubMetadataRecord : navMetadataRecord.Navigational_Subtopic_Informations__r){
                        topicNameSet.add(navSubMetadataRecord.MasterLabel.toLowerCase().trim());
                        if(navTopicToSubTopicMap.containsKey(navMetadataRecord.MasterLabel)){
                            navTopicToSubTopicMap.get(navMetadataRecord.MasterLabel.toLowerCase().trim()).add(navSubMetadataRecord.MasterLabel.toLowerCase().trim());
                        }else{
                            navTopicToSubTopicMap.put(navMetadataRecord.MasterLabel.toLowerCase().trim(),new set<String>{navSubMetadataRecord.MasterLabel.toLowerCase().trim()});
                        } 
                    }
                }
            }
        }
        //String communityId = '0DB010000004CGOGA2'; //'0DB010000004CGOGA2';
        
        Map<String,String> topicNameToIdMap = new Map<String,String>();
        List<topic> topicList = [SELECT Id, NetworkId, Name, Description, ManagedTopicType FROM Topic Where Name IN :topicNameSet and NetworkId = :communityId];
        if(topicList != null && topicList.size() > 0){
            for(Topic topicRec : topicList){
                topicNameToIdMap.put(topicRec.Name.toLowerCase().trim(),topicRec.Id);
            }
        }
        
        List<NavigationalTopicWrapper> NavigationalWrapperList = new  List<NavigationalTopicWrapper>();
        if(navigationTopicList != null && navigationTopicList.size() > 0){
            for(NavigationalTopicInformation__mdt navMetadataRecord : navigationTopicList){
                if(topicNameToIdMap.containsKey(navMetadataRecord.MasterLabel.toLowerCase().trim())){
                    NavigationalTopicWrapper navTopicObj = new NavigationalTopicWrapper(navMetadataRecord.MasterLabel,topicNameToIdMap.get(navMetadataRecord.MasterLabel.toLowerCase().trim()),navMetadataRecord.Icon_Name__c);
                	if(navMetadataRecord.Navigational_Subtopic_Informations__r != null && navMetadataRecord.Navigational_Subtopic_Informations__r.size() > 0){
                        List<NavigationalSubTopicWrapper> subWrapList = new List<NavigationalSubTopicWrapper>();
                        for(Navigational_Subtopic_Information__mdt navSubMetadataRecord : navMetadataRecord.Navigational_Subtopic_Informations__r){
                            if(topicNameToIdMap.containsKey(navSubMetadataRecord.MasterLabel.toLowerCase().trim())){
                                subWrapList.add(new NavigationalSubTopicWrapper(navSubMetadataRecord.MasterLabel,topicNameToIdMap.get(navSubMetadataRecord.MasterLabel.toLowerCase().trim())));
                            }
                        }
                        navTopicObj.subTopicList = subWrapList;
                    }
                    NavigationalWrapperList.add(navTopicObj);
                }
            }
        }
        return NavigationalWrapperList;
        
    }
    
    Public Class NavigationalTopicWrapper{
        @AuraEnabled Public String Name;
        @AuraEnabled Public String topicId;
        @AuraEnabled Public String IconName;
        @AuraEnabled Public List<NavigationalSubTopicWrapper> subTopicList;
        public NavigationalTopicWrapper(String Name,String topicId,String IconName){
            this.name = Name;
            this.topicId = topicId;
            this.IconName = IconName;
        }
    }
    
    Public Class NavigationalSubTopicWrapper{
        @AuraEnabled Public String Name;
        @AuraEnabled Public String subTopicId;
        public NavigationalSubTopicWrapper(String Name,String subTopicId){
            this.Name = Name;
            this.subTopicId = subTopicId;
        }
    }
}