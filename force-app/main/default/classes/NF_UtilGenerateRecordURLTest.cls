@IsTest
public with sharing class NF_UtilGenerateRecordURLTest {

    @IsTest
    public static void testRecordURLGeneration() {
        List<NF_UtilGenerateRecordURL.RecordURLParams> recParams = new List<NF_UtilGenerateRecordURL.RecordURLParams>();
        NF_UtilGenerateRecordURL.RecordURLParams param = new NF_UtilGenerateRecordURL.RecordURLParams();
        param.recordId = 'ABC';
        recParams.add(param);
        
        List<NF_UtilGenerateRecordURL.RecordURLResult> urlResults = NF_UtilGenerateRecordURL.generateRecordURL(recParams);
        NF_UtilGenerateRecordURL.RecordURLResult urlResult = urlResults[0];
        String startURL = urlResult.url.left(4);
        String endURL = urlResult.url.right(3);

        System.assertEquals(endURL, 'ABC', 'URL in test should end with ABC');
        System.assertEquals(startURL, 'http', 'URL in test should start with http');
    }
}