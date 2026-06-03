/****************************************************************************************************************
* Program Name         : SCS_WordCloudController
* Description          : Controller class for scs_WordCloud LWC
* Version              : 1.1
* Modification Log     : 11 May,2021.
*------------------------------------------------------------------------------------------------------------------------------
* RequirementId     JiraId     Version     Developer          Date           Description
*------------------------------------------------------------------------------------------------------------------------------
*   CB_01          DP-38414      1.1    Chayan Batabyal    11 May,2021      Queries on the latest Social Post records and looks for
                                                                            certain field values, clears out the bogus words/characters
                                                                            and sends them to the LWC which then generates a word cloud
                                                                            from by calculating the words that appear most frequently.
*****************************************************************************************************************/
public with sharing class SCS_WordCloudController {
    /**
    * @description Queries as per the given conditions and returns the response
    * @author cbatabyal@contractor.lb.com | 05-11-2021
    * @param objectAPIName
    * @param fieldAPINames
    * @param whereCondition
    * @return WordCloudResponse
    **/
    @AuraEnabled
    public static WordCloudResponse getRecordDetails(
        String objectAPIName, String fieldAPINames, String whereCondition
    ){
        WordCloudResponse objResponse = new WordCloudResponse();

        try{
            objResponse.values = new List<String>();

            String queryString = 'SELECT fieldAPINames FROM objectAPIName';

            if(String.isNotBlank(whereCondition)){
                queryString += ' WHERE '+ String.escapeSingleQuotes(whereCondition).replaceAll('"', '\'');
            }

            queryString = queryString.replace('fieldAPINames', fieldAPINames)
                .replace('objectAPIName', objectAPIName)+ ' LIMIT 50000';
			queryString = queryString.trim().replaceAll('\\s+', ' ');
            System.debug('queryString :: ' + queryString);
            for(SObject eachRecord : Database.query(queryString)){
                String value = '';
                for(String eachField : fieldAPINames.split(',')){
                    value += (
                        ((String)eachRecord.get(eachField))
                        .replaceAll('\n', ' ').replaceAll('\r', ' ')
                        .replaceAll('\t', ' ') + ' '
                    ).replaceAll('\\s+', ' ');
                }

                String finalValue = '';
                for(String eachWord : value.trim().split(' ')){
                    System.debug('eachWord :: ' + eachWord);
                    for(String eachJunkWord : LABEL.SCS_WORD_CLOUD_JUNK_WORDS.split(' ')){
                        if(
                            String.escapeSingleQuotes(eachWord).remove(',')
                            .equalsIgnoreCase(String.escapeSingleQuotes(eachJunkWord))
                        ){
                            eachWord = '';
                            break;
                        }
                    }
                    if(String.isNotBlank(eachWord)){
                        finalValue += (' ' + eachWord.replaceAll(',', ' '));
                    }
                }

                objResponse.values.add(finalValue.trim().replaceAll('\\s+', ' ').toUpperCase());
            }

            objResponse.isSuccess = true;
        }
        catch(Exception e){
            String message = e.getMessage() + ' at Line Number ' + e.getLineNumber();
            System.debug('Exception Occured : ' + message);
            objResponse.message = message;
        }

        return objResponse;
    }

    public class WordCloudResponse{
        @AuraEnabled
        public List<String> values;

        @AuraEnabled
        public Boolean isSuccess = false;

        @AuraEnabled
        public String message;
    }
}