@isTest
private class MaxMindServiceTest {

    @testSetup
    static void createTestData() {
        List<MaxMindSettings__c> settings = new List<MaxMindSettings__c>{
            new MaxMindSettings__c(
                Name = 'AuthorizationHeader',
                Value__c = 'Test'),
            new MaxMindSettings__c(
                Name = 'RequestURL',
                Value__c = 'https://www.example.com/')
        };
        insert settings; 
    }

    // Test a successful MaxMind callout
    @isTest
    static void getGeoIpSuccessTest() {

        Test.setMock(HttpCalloutMock.class, new MaxMindServiceMock());

        Test.startTest();

        MaxMindService service = new MaxMindService();
        
        MaxMindGeoIpResult result = service.getGeoIp('96.10.225.162');

        Test.stopTest();

        System.assert(result.rawRequest != null);
        System.assert(result.rawResponse != null);
        System.assert(result.errorMessage == null);

        System.assertEquals('Raleigh', result.city.names.en);
        System.assertEquals('Raleigh', result.city.names.pt_BR);
        System.assertEquals('North America', result.continent.names.en);
        System.assertEquals('US', result.country.iso_code);
        System.assertEquals('America/New_York', result.location.time_zone);
        System.assertEquals(182480, result.maxmind.queries_remaining);
        System.assertEquals('27607', result.postal.code);
        System.assertEquals('US', result.registered_country.iso_code);

        System.assert(result.city.confidence != null);
        System.assert(result.city.geoname_id != null);
        System.assert(result.city.names.es != null);
        System.assert(result.city.names.fr != null);
        System.assert(result.city.names.ja != null);
        System.assert(result.city.names.pt_BR != null);
        System.assert(result.city.names.ru != null);
        System.assert(result.city.names.zh_CN != null);
        System.assert(result.city.names.de != null);
        System.assert(result.city.names.en != null);

        System.assert(result.continent.code != null);
        System.assert(result.continent.geoname_id != null);
        System.assert(result.continent.names != null);

        System.assert(result.country.confidence != null);
        System.assert(result.country.iso_code != null);
        System.assert(result.country.geoname_id != null);
        System.assert(result.country.names != null);

        System.assert(result.location.average_income != null);
        System.assert(result.location.population_density != null);
        System.assert(result.location.accuracy_radius != null);
        System.assert(result.location.latitude != null);
        System.assert(result.location.longitude != null);
        System.assert(result.location.metro_code != null);
        System.assert(result.location.time_zone != null);

        System.assert(result.maxmind.queries_remaining != null);

        System.assert(result.postal.confidence != null);
        System.assert(result.postal.code != null);

        System.assert(result.registered_country.iso_code != null);
        System.assert(result.registered_country.geoname_id != null);
        System.assert(result.registered_country.names != null);

        System.assert(result.subdivisions[0].confidence != null);
        System.assert(result.subdivisions[0].iso_code != null);
        System.assert(result.subdivisions[0].geoname_id != null);
        System.assert(result.subdivisions[0].names != null);

        System.assert(result.traits.user_type != null);
        System.assert(result.traits.autonomous_system_number != null);
        System.assert(result.traits.autonomous_system_organization != null);
        System.assert(result.traits.domain != null);
        System.assert(result.traits.isp != null);
        System.assert(result.traits.organization != null);
        System.assert(result.traits.ip_address != null);
    }

    // Test a failed MaxMind callout
    @isTest
    static void getGeoIpFailureTest() {

        Test.setMock(HttpCalloutMock.class, new MaxMindServiceMock(400, 
            [SELECT Body FROM StaticResource WHERE Name = 'MaxMindGeoIpFailureResponse'].Body.toString()));

        Test.startTest();

        MaxMindService service = new MaxMindService();
        
        MaxMindGeoIpResult result = service.getGeoIp('127.0.0.1');

        Test.stopTest();

        System.assert(result.rawRequest != null);
        System.assert(result.rawResponse != null);
        System.assert(result.errorMessage != null);
    }

    // Test a call to the service with a null IP address
    @isTest
    static void getGeoIpNullTest() {

        Test.startTest();

        MaxMindService service = new MaxMindService();
        
        MaxMindGeoIpResult result = service.getGeoIp(null);

        Test.stopTest();

        System.assert(result.rawRequest == null);
        System.assert(result.rawResponse == null);
        System.assert(result.errorMessage != null);
        System.assertEquals('ipAddress must not be null', result.errorMessage);
    }
}