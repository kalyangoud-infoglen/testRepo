@isTest
private class AmberRoadServiceTest {

    @testSetup
    static void createTestData() {
        List<AmberRoadSettings__c> settings = new List<AmberRoadSettings__c>{
            new AmberRoadSettings__c(
                Name = 'AuthorizationHeader',
                Value__c = 'Test'),
            new AmberRoadSettings__c(
                Name = 'RequestURL',
                Value__c = 'https://www.example.com')
        };
        insert settings;   
    }

    // Test a successful Amber Road callout
    @isTest
    static void performScreeningSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock());

        Test.startTest();

        AmberRoadService service = new AmberRoadService();
        
        AmberRoadResult result = service.performScreening(
            'TEST001', 
            'R7TEST',
            'Test Corp',
            'Test Lead',
            null,
            null,
            null,
            null,
            null,
            'NC',
            'North Carolina',
            '27601',
            'US',
            'United States'
        );

        String responseXML = result.rawResponse;

        Test.stopTest();

        System.assertEquals('Cleared', result.status);
    }

    // Test a failed Amber Road callout
    @isTest
    static void performScreeningHTTPFailureTest() {
        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock(400, 'some error response'));

        Test.startTest();

        AmberRoadService service = new AmberRoadService();
        
        AmberRoadResult result = service.performScreening(
            'TEST001', 
            'R7TEST',
            'Test Corp',
            'Test Lead',
            null,
            null,
            null,
            null,
            null,
            'NC',
            'North Carolina',
            '27601',
            'US',
            'United States'
        );

        String responseXML = result.rawResponse;

        Test.stopTest();

        System.assertEquals('Error', result.status);
    }

    // Test a failed Amber Road callout
    @isTest
    static void performScreeningServiceFailureTest() {
        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock(200, 
                '<?xml version="1.0" encoding="UTF-8"?><Partner><Error>Amber Road Error Message</Error></Partner>'));

        Test.startTest();

        AmberRoadService service = new AmberRoadService();
        
        AmberRoadResult result = service.performScreening(
            'TEST001', 
            'R7TEST',
            'Test Corp',
            'Test Lead',
            null,
            null,
            null,
            null,
            null,
            'NC',
            'North Carolina',
            '27601',
            'US',
            'United States'
        );

        String responseXML = result.rawResponse;

        Test.stopTest();

        System.assertEquals('Error', result.status);
    }

    // Test lead XML generation
    @isTest 
    static void generateAmberRoadXmlTest() {
        Test.startTest();

        AmberRoadService service = new AmberRoadService();
        String request = service.generateAmberRoadXML(
            'TEST001', 
            'R7TEST',
            'Test Corp',
            'Test Lead',
            null,
            null,
            null,
            null,
            null,
            'NC',
            'North Carolina',
            '27601',
            'US',
            'United States'
        );

        Test.stopTest();

        DOM.Document requestXML = new DOM.Document();
        requestXML.load(request);
        Dom.XMLNode requestPartnerNode = requestXML.getRootElement();

        System.assertEquals('TEST001', requestPartnerNode.getAttributeValue('PartnerID', null));
        System.assertEquals('', requestPartnerNode.getAttributeValue('City', null));
        System.assertEquals('US', requestPartnerNode.getAttributeValue('CountryCode', null));  
    }
}