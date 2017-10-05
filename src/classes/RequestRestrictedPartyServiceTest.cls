/**
 * This class provides unit tests for RequestRestrictedPartyService
 */
@isTest
private class RequestRestrictedPartyServiceTest {

    @testSetup
    static void createTestData() {

        AmberRoadRequest__c testRequest1 = new AmberRoadRequest__c(
            Name = 'Test Lead',
            CountryCode__c = 'US',
            Company__c = 'Test Corp',
            RestrictedPartyJobStatus__c = 'Skipped',
            IP__c = '96.10.225.162'
        );
        insert testRequest1;

        List<AmberRoadSettings__c> settings = new List<AmberRoadSettings__c>{
            new AmberRoadSettings__c(
                Name = 'AuthorizationHeader',
                Value__c = 'Test'),
            new AmberRoadSettings__c(
                Name = 'RequestURL',
                Value__c = 'https://www.example.com/amberroad')
        };
        insert settings;

        List<MaxMindSettings__c> settings2 = new List<MaxMindSettings__c>{
            new MaxMindSettings__c(
                Name = 'AuthorizationHeader',
                Value__c = 'Test'),
            new MaxMindSettings__c(
                Name = 'RequestURL',
                Value__c = 'https://www.example.com/maxmind')
        };
        insert settings2; 
    }

    // Test the public performScreening() method
    @isTest
    static void performScreeningTest() {
        List<AmberRoadRequest__c> requests = [Select Id, RestrictedPartyStatus__c From AmberRoadRequest__c];
        
        for(AmberRoadRequest__c request : requests) {
            System.assert(String.isBlank(request.RestrictedPartyStatus__c));
        }

        List<Id> requestIds = new List<Id>();
        for(AmberRoadRequest__c request : requests) {
            requestIds.add(request.Id);
        }

        Test.setMock(HttpCalloutMock.class, new RequestRestrictedPartyServiceMock());

        Test.startTest();

        RequestRestrictedPartyService service = new RequestRestrictedPartyService();
        service.performScreening(requestIds);

        Test.stopTest();

        requests = [Select Id, RestrictedPartyStatus__c From AmberRoadRequest__c];
        for(AmberRoadRequest__c request : requests) {
            System.assertEquals('Cleared', request.RestrictedPartyStatus__c);
        }
    }

    // Test the public performScreening() method with an embargoed city
    @isTest
    static void performScreeningEmbargoCityTest() {
        EmbargoCity__c city = new EmbargoCity__c(
            Name = 'Raleigh',
            CountryCode__c = 'US'
        );
        insert city;

        List<AmberRoadRequest__c> requests = [Select Id, RestrictedPartyStatus__c From AmberRoadRequest__c];
        
        for(AmberRoadRequest__c request : requests) {
            System.assert(String.isBlank(request.RestrictedPartyStatus__c));
        }

        List<Id> requestIds = new List<Id>();
        for(AmberRoadRequest__c request : requests) {
            requestIds.add(request.Id);
        }

        Test.setMock(HttpCalloutMock.class, new RequestRestrictedPartyServiceMock());

        Test.startTest();

        RequestRestrictedPartyService service = new RequestRestrictedPartyService();
        service.performScreening(requestIds);

        Test.stopTest();

        requests = [Select Id, RestrictedPartyStatus__c From AmberRoadRequest__c];
        for(AmberRoadRequest__c request : requests) {
            System.assertEquals('Flagged', request.RestrictedPartyStatus__c);
        }
    }

    // Test the public performScreening() method with an embargoed domain
    @isTest
    static void performScreeningEmbargoDomainTest() {
        EmbargoDomain__c domain = new EmbargoDomain__c(
            Name = 'rr.com'
        );
        insert domain;

        List<AmberRoadRequest__c> requests = [Select Id, RestrictedPartyStatus__c From AmberRoadRequest__c];
        
        for(AmberRoadRequest__c request : requests) {
            System.assert(String.isBlank(request.RestrictedPartyStatus__c));
        }

        List<Id> requestIds = new List<Id>();
        for(AmberRoadRequest__c request : requests) {
            requestIds.add(request.Id);
        }

        Test.setMock(HttpCalloutMock.class, new RequestRestrictedPartyServiceMock());

        Test.startTest();

        RequestRestrictedPartyService service = new RequestRestrictedPartyService();
        service.performScreening(requestIds);

        Test.stopTest();

        requests = [Select Id, RestrictedPartyStatus__c From AmberRoadRequest__c];
        for(AmberRoadRequest__c request : requests) {
            System.assertEquals('Flagged', request.RestrictedPartyStatus__c);
        }
    }

    // Test a successful RPS callout using the private performScreening() method
    @isTest
    static void performScreeningSuccessTest() {
        AmberRoadRequest__c testRequest = [
            Select Id, AmberRoadServiceRequest__c, AmberRoadServiceResponse__c,
                Address1__c, Address2__c, Address3__c, City__c, 
                Company__c, CountryCode__c, Name, Name__c, PostalCode__c, 
                RestrictedPartyStatus__c, RestrictedPartyJobStatus__c, StateCode__c
            From AmberRoadRequest__c 
            Where Name = 'Test Lead'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock());

        Test.startTest();

        RequestRestrictedPartyService service = new RequestRestrictedPartyService();
        service.performScreening(testRequest);

        Test.stopTest();

        System.assertEquals('Cleared', testRequest.RestrictedPartyStatus__c);
        System.assert(String.isNotBlank(testRequest.AmberRoadServiceRequest__c));
        System.assert(String.isNotBlank(testRequest.AmberRoadServiceResponse__c));
    }

    // Test a HTTP status code != 200
    @isTest
    static void performScreeningFailureTest() {
        AmberRoadRequest__c testRequest = [
            Select Id, AmberRoadServiceRequest__c, AmberRoadServiceResponse__c, 
                Address1__c, Address2__c, Address3__c, City__c, 
                Company__c, CountryCode__c, Name, Name__c, PostalCode__c, 
                RestrictedPartyStatus__c, RestrictedPartyJobStatus__c, StateCode__c
            From AmberRoadRequest__c 
            Where Name = 'Test Lead'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new AmberRoadServiceMock(400, 'some error response'));

        Test.startTest();

        RequestRestrictedPartyService service = new RequestRestrictedPartyService();
        service.performScreening(testRequest);

        Test.stopTest();

        System.assertEquals('Error', testRequest.RestrictedPartyStatus__c);
        System.assert(String.isNotBlank(testRequest.AmberRoadServiceRequest__c));
        System.assert(String.isNotBlank(testRequest.AmberRoadServiceResponse__c));
    }

    // Test a successful GeoIP callout using the private performEmbargoCheck() method
    @isTest
    static void performEmbargoCheckSuccessTest() {
        AmberRoadRequest__c testRequest = [
            Select Id, MaxMindServiceRequest__c, MaxMindServiceResponse__c,
                Address1__c, Address2__c, Address3__c, City__c, 
                Company__c, CountryCode__c, Email__c, IP__c, Name, Name__c, PostalCode__c, 
                RestrictedPartyStatus__c, RestrictedPartyJobStatus__c, StateCode__c
            From AmberRoadRequest__c 
            Where Name = 'Test Lead'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new MaxMindServiceMock());

        Test.startTest();

        RequestRestrictedPartyService service = new RequestRestrictedPartyService();
        service.performEmbargoCheck(testRequest);

        Test.stopTest();

        System.assert(String.isNotBlank(testRequest.MaxMindServiceRequest__c));
        System.assert(String.isNotBlank(testRequest.MaxMindServiceResponse__c));
    }
}