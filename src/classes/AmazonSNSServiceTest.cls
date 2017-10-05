@isTest
private class AmazonSNSServiceTest {

    @testSetup
    static void createTestData() {
        AmazonSettings__c settings = new AmazonSettings__c(
            Name = 'TestSettings',
            Endpoint__c = 'http://snsendpoint.example.com/',
            Region__c = 'aws-region',
            AccessKey__c = 'ABCD12345',
            SecretAccessKey__c = 'qwertyuiop1234567890',
            ARN__c = 'aws:arn:111111111:sometopic'
        );
        insert settings;
    }

    // Test a successful Amazon SNS publish action
    @isTest
    static void publishSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new AmazonSNSServiceMock());

        Test.startTest();

        AmazonSNSService SNS = new AmazonSNSService('TestSettings');
        AmazonSNSResult result = SNS.publish('This is a test message.');

        Test.stopTest();

        System.assertEquals('Success', result.status);
    }

    // Test a failed Amazon SNS publish action
    @isTest
    static void publishFailureTest() {
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

        AmazonSNSService SNS = new AmazonSNSService('TestSettings');
        AmazonSNSResult result = SNS.publish('This is a test message.');

        Test.stopTest();

        System.assertEquals('Error', result.status);
        System.assert(result.rawRequest != null);
        System.assert(result.rawResponse != null);
    }

    // Test failed service instantiation due to missing settings
    @isTest
    static void missingSettingsTest() {

        Test.startTest();

        String errorMessage = null;
        try {
            AmazonSNSService SNS = new AmazonSNSService('MissingSettings');
        }
        catch (Exception ex) {
            errorMessage = ex.getMessage();
        }

        Test.stopTest();

        System.assert(errorMessage != null);
    }
}