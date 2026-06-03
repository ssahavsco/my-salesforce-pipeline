@isTest
public with sharing class VS_CollectiveCarouselContentTest {

    @istest
    static void CarouselContent_Available_Test(){
        VS_CollectiveCarouselContent.Input i = new VS_CollectiveCarouselContent.Input();
        i.latestRewardDate = 'Dec 31';
        List<VS_CollectiveCarouselContent.Input> input = new List<VS_CollectiveCarouselContent.Input>();
        input.add(i);
        VS_CollectiveCarouselContent.CarouselContent_Available(input);
    }

    @istest
    static void CarouselContent_NotAvailable(){
        VS_CollectiveCarouselContent.CarouselContent_NotAvailable();
    }
}