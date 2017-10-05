/**
 * This class provides unit tests for RequestPublishResultService
 */
@isTest
private class RequestPublishResultServiceTest {

    @testSetup
    static void createTestData() {

        AmberRoadRequest__c testRequest1 = new AmberRoadRequest__c(
            Name = 'Test Request 1',
            CountryCode__c = 'US',
            Company__c = 'Test Corp',
            RestrictedPartyJobStatus__c = 'Success',
            RestrictedPartyStatus__c = 'Cleared',
            RestrictedPartyStatusDate__c = Date.today(),
            RestrictedPartyStatusDetails__c = null,
            PublishResultJobStatus__c = 'Skipped'
        );
        insert testRequest1;

        AmberRoadRequest__c testRequest2 = new AmberRoadRequest__c(
            Name = 'Test Request 2',
            CountryCode__c = 'US',
            Company__c = 'Test Corp',
            RestrictedPartyJobStatus__c = 'Success',
            RestrictedPartyStatus__c = 'Error',
            RestrictedPartyStatusDate__c = null,
            RestrictedPartyStatusDetails__c = 'There was an error',
            PublishResultJobStatus__c = 'Skipped'
        );
        insert testRequest2;

        AmazonSettings__c settings = new AmazonSettings__c(
            Name = 'RestrictedScreeningSNS',
            Endpoint__c = 'http://snsendpoint.example.com/',
            Region__c = 'aws-region',
            AccessKey__c = 'ABCD12345',
            SecretAccessKey__c = 'qwertyuiop1234567890',
            ARN__c = 'aws:arn:111111111:sometopic'
        );
        insert settings;  
    }

    // Test the public publishResult() method
    @isTest
    static void publishResultTest() {
        List<AmberRoadRequest__c> requests = [Select Id From AmberRoadRequest__c];
        List<Id> requestIds = new List<Id>();
        for (AmberRoadRequest__c request : requests) {
            requestIds.add(request.Id);
        }

        Test.setMock(HttpCalloutMock.class, new AmazonSNSServiceMock());

        Test.startTest();

        RequestPublishResultService service = new RequestPublishResultService();
        requests = service.publishResult(requestIds);

        Test.stopTest();

        for (AmberRoadRequest__c request : requests) {
            System.assertEquals('Success', request.PublishResultStatus__c);
        }
    }

    // Test a successful Amazon SNS callout using the private publishResult() method
    @isTest
    static void publishResultSuccessTest() {
        AmberRoadRequest__c testRequest = [
            Select Id, Address1__c, Address2__c, Address3__c, City__c,
                Company__c, CountryCode__c, Name, Name__c, PostalCode__c,
                PublishResultStatus__c, PublishResultStatusDetails__c,
                RestrictedPartyStatus__c, RestrictedPartyStatusDate__c,
                RestrictedPartyStatusDetails__c, RestrictedPartyJobStatus__c,
                StateCode__c
            From AmberRoadRequest__c 
            Where Name = 'Test Request 2'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new AmazonSNSServiceMock());

        Test.startTest();

        RequestPublishResultService service = new RequestPublishResultService();
        service.publishResult(testRequest);

        Test.stopTest();

        System.assertEquals('Success', testRequest.PublishResultStatus__c);
        System.assert(String.isNotEmpty(testRequest.AmazonSNSServiceRequest__c));
        System.assert(String.isNotEmpty(testRequest.AmazonSNSServiceResponse__c));
    }

    // Test a successful Amazon SNS callout using the private publishResult() method
    @isTest
    static void publishResultFailureTest() {
        AmberRoadRequest__c testRequest = [
            Select Id, Address1__c, Address2__c, Address3__c, City__c,
                Company__c, CountryCode__c, Name, Name__c, PostalCode__c,
                PublishResultStatus__c, PublishResultStatusDetails__c,
                RestrictedPartyStatus__c, RestrictedPartyStatusDate__c,
                RestrictedPartyStatusDetails__c, RestrictedPartyJobStatus__c,
                StateCode__c
            From AmberRoadRequest__c 
            Where Name = 'Test Request 1'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class,
            new AmazonSNSServiceMock(
                400,
                '<ErrorResponse xmlns="http://webservices.amazon.com/AWSFault/2005-15-09">' +
                '  <Error>' +
                '    <Type>Sender</Type>' +
                '    <Code>InvalidAction</Code>' +
                '    <Message>Could not find operation XPublish for version 2010-03-31</Message>' +
                '  </Error>' +
                '  <RequestId>9e524320-3726-529c-b33b-113ed9be6797</RequestId>' +
                '</ErrorResponse>'
            )
        );

        Test.startTest();

        RequestPublishResultService service = new RequestPublishResultService();
        service.publishResult(testRequest);

        Test.stopTest();

        System.assertEquals('Error', testRequest.PublishResultStatus__c);
        System.assertEquals('Could not find operation XPublish for version 2010-03-31', testRequest.PublishResultStatusDetails__c);
        System.assert(String.isNotEmpty(testRequest.AmazonSNSServiceRequest__c));
        System.assert(String.isNotEmpty(testRequest.AmazonSNSServiceResponse__c));
    }

}