/**
 * Created by mcasella on 10/27/20.
 */

@IsTest
public with sharing class NF_GetChatTranscriptDataTest {

    @IsTest
    static void getTranscript(){
        String chatKey = 'abc';
        LiveChatTranscript transcript = NF_UtilTest.insertLiveChatTranscript(chatKey, '', '');
        List<LiveChatTranscript> transcripts = NF_GetChatTranscriptData.getChatTranscriptData(transcript.Id);
        System.assertEquals(1, transcripts.size());
    }
}