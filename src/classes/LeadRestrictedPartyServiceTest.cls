/**
 * This class provides unit tests for LeadLicenseKeyService
 */
@isTest
private class LeadRestrictedPartyServiceTest {

    @testSetup
    static void createTestData() {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;

        Lead testLead1 = new Lead(
            FirstName = 'Test', 
            LastName = 'Lead', 
            Country = 'United States',
            CountryCode = 'US', 
            Title = 'Senior Test', 
            Email = 'test@example.com',
            Phone = '800-555-1212', 
            Company = 'Test Corp', 
            LeadSource = 'Freemium', 
            LrpSid__c = '1234567890',
            RemoteIp__c = '10.1.1.1',
            Industry = 'Business',
            AccessCode__c = '123XYZ',
            MergeJobStatus__c = 'Skipped',
            RestrictedPartyJobStatus__c = 'Skipped',
            SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS
        );
        Database.insert(testLead1, dmlOptions);

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

    // Test the public performScreening() method
    @isTest
    static void performScreeningTest() {
        List<Lead> leads = [Select Id From Lead];
        List<Id> leadIds = new List<Id>();
        for(Lead lead : leads) {
            leadIds.add(lead.Id);
        }

        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock());

        Test.startTest();

        LeadRestrictedPartyService service = new LeadRestrictedPartyService();
        service.performScreening(leadIds);

        Test.stopTest();
    }

    // Test a successful RPS callout using the private performScreening() method
    @isTest
    static void performScreeningSuccessTest() {
        Lead testLead = [
            Select Id, City, Company, Country, CountryCode, FirstName, 
                   LastName, PostalCode, RestrictedPartyJobStatus__c, State, StateCode, Street
            From Lead 
            Where Email = 'test@example.com'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock());

        Test.startTest();

        LeadRestrictedPartyService service = new LeadRestrictedPartyService();
        String responseXML = service.performScreening(testLead);

        Test.stopTest();

        System.assertEquals('Cleared', testLead.RestrictedPartyStatus__c);
        System.assert(String.isNotBlank(testLead.RestrictedPartyStatusDetails__c));
    }

    // Test a HTTP status code != 200
    @isTest
    static void performScreeningFailureTest() {
        Lead testLead = [
            Select Id, City, Company, Country, CountryCode, FirstName, 
                   LastName, PostalCode, RestrictedPartyJobStatus__c, State, StateCode, Street
            From Lead 
            Where Email = 'test@example.com'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock(400, 'some error response'));

        Test.startTest();

        LeadRestrictedPartyService service = new LeadRestrictedPartyService();
        String responseXML = service.performScreening(testLead);

        Test.stopTest();

        System.assertEquals('Error', testLead.RestrictedPartyStatus__c);
        System.assert(String.isNotBlank(testLead.RestrictedPartyStatusDetails__c));
    }

    // Test a response that contains an error message from Amber Road
    @isTest
    static void createNetsuiteLRPFailure2Test() {
        Lead testLead = [
            Select Id, City, Company, Country, CountryCode, FirstName, 
                   LastName, PostalCode, RestrictedPartyJobStatus__c, State, StateCode, Street
            From Lead 
            Where Email = 'test@example.com'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock(200, 
                '<?xml version="1.0" encoding="UTF-8"?><Partner><Error>Amber Road Error Message</Error></Partner>'));

        Test.startTest();

        LeadRestrictedPartyService service = new LeadRestrictedPartyService();
        String responseXML = service.performScreening(testLead);

        Test.stopTest();

        System.assertEquals('Error', testLead.RestrictedPartyStatus__c);
        System.assert(String.isNotBlank(testLead.RestrictedPartyStatusDetails__c));
    }
}