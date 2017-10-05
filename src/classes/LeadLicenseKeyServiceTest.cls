/**
 * This class provides unit tests for LeadLicenseKeyService
 */
@isTest
private class LeadLicenseKeyServiceTest {

    @testSetup
    static void createTestData() {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;

        Lead testLead1 = new Lead(
            FirstName = 'Test', 
            LastName = 'Lead', 
            Country = 'United States', 
            Title = 'Senior Test', 
            Email = 'test@example.com',
            Phone = '800-555-1212', 
            Company = 'Test Corp', 
            LeadSource = 'Freemium', 
            LrpSid__c = '1234567890',
            RemoteIp__c = '10.1.1.1',
            TypeOfUse__c = 'Business',
            AccessCode__c = '123XYZ',
            SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            RestrictedPartyJobStatus__c = 'Skipped',
            LicenseKeyJobStatus__c = 'Skipped'
        );
        Database.insert(testLead1, dmlOptions);

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            NetsuiteCampaignInternalId__c = '121212'
        );
        insert testCampaign;

        CampaignMember testCampaignMember1 = new CampaignMember(
            LeadId = testLead1.Id,
            CampaignId = testCampaign.Id 
        );
        insert testCampaignMember1;

        OauthCredential__c credential = new OauthCredential__c(
            Name = 'LEAD_SEARCH_SERVICE',
            Realm__c = 'Test', 
            ConsumerKey__c = 'Test', 
            ConsumerSecret__c = 'Test', 
            Token__c = 'Test', 
            TokenSecret__c = 'Test'
        );
        insert credential;      
    }

    // Test the public generateLicenseKeys() method
    @isTest
    static void generateLicenseKeysTest() {
        List<Lead> leads = [Select Id From Lead];
        List<Id> leadIds = new List<Id>();
        for(Lead lead : leads) {
            leadIds.add(lead.Id);
        }

        Test.setMock(HttpCalloutMock.class, new LeadLicenseKeyServiceMock(200));

        Test.startTest();

        LeadLicenseKeyService service = new LeadLicenseKeyService();
        service.generateLicenseKeys(leadIds);

        Test.stopTest();
    }

    // Test a successful LRP creation
    @isTest
    static void createNetsuiteLRPSuccessTest() {
        Lead testLead = [
            Select Id, AccessCode__c, Company, Country, CountryCode, Email, FirstName, TypeOfUse__c, LastName, LeadSource,
                LicenseKeyStatus__c, LrpSid__c, Phone, RemoteIp__c, RestrictedPartyStatus__c, RestrictedPartyStatusDate__c, Title,
                (Select CampaignId, CreatedDate, Campaign.NetsuiteCampaignInternalId__c 
                 From CampaignMembers 
                 Order By CreatedDate DESC 
                 Limit 1)
            From Lead 
            Where LrpSid__c = '1234567890'
            Limit 1
        ];

        Test.setMock(HttpCalloutMock.class, new LeadLicenseKeyServiceMock(200));

        Test.startTest();

        LeadLicenseKeyService service = new LeadLicenseKeyService();
        String responseJSON = service.createNetsuiteLRP(testLead);

        Test.stopTest();

        Map<String, Object> responseJSONMap = (Map<String, Object>) JSON.deserializeUntyped(responseJSON);
        System.assert(responseJSONMap.containsKey('LRP_id'));
        System.assert(responseJSONMap.containsKey('LRP_status'));
        System.assertEquals('Approved', testLead.LicenseKeyStatus__c);
        System.assert(String.isNotBlank(testLead.LicenseKeyStatusDetails__c));
    }

    // Test a HTTP status code != 200
    @isTest
    static void createNetsuiteLRPFailureTest() {
        Lead testLead = [
            Select Id, AccessCode__c, Company, Country, CountryCode, Email, FirstName, TypeOfUse__c, LastName, LeadSource,
                LicenseKeyStatus__c, LrpSid__c, Phone, RemoteIp__c, RestrictedPartyStatus__c, RestrictedPartyStatusDate__c, Title,
                (Select CampaignId, CreatedDate, Campaign.NetsuiteCampaignInternalId__c 
                 From CampaignMembers 
                 Order By CreatedDate DESC 
                 Limit 1)
            From Lead 
            Where LrpSid__c = '1234567890'
            Limit 1];

        Test.setMock(HttpCalloutMock.class, new LeadLicenseKeyServiceMock(400));

        Test.startTest();

        LeadLicenseKeyService service = new LeadLicenseKeyService();
        String responseJSON = service.createNetsuiteLRP(testLead);

        Test.stopTest();

        System.assertEquals('Error', testLead.LicenseKeyStatus__c);
        System.assert(String.isNotBlank(testLead.LicenseKeyStatusDetails__c));
    }

    // Test a response that contains an error message from Netsuite
    @isTest
    static void createNetsuiteLRPFailure2Test() {
        Lead testLead = [
            Select Id, AccessCode__c, Company, Country, CountryCode, Email, FirstName, TypeOfUse__c, LastName, LeadSource,
                LicenseKeyStatus__c, LrpSid__c, Phone, RemoteIp__c, RestrictedPartyStatus__c, RestrictedPartyStatusDate__c, Title,
                (Select CampaignId, CreatedDate, Campaign.NetsuiteCampaignInternalId__c 
                 From CampaignMembers 
                 Order By CreatedDate DESC 
                 Limit 1)
            From Lead 
            Where LrpSid__c = '1234567890'
            Limit 1];

        Test.setMock(HttpCalloutMock.class, new LeadLicenseKeyServiceMock(200, '{"error":{"code":"INVALID_FIRST_NAME","message":"First name is required"}}'));

        Test.startTest();

        LeadLicenseKeyService service = new LeadLicenseKeyService();
        String responseJSON = service.createNetsuiteLRP(testLead);

        Test.stopTest();

        System.assertEquals('Error', testLead.LicenseKeyStatus__c);
        System.assert(String.isNotBlank(testLead.LicenseKeyStatusDetails__c));
    }

    // Test lrp JSON generation
    @isTest 
    static void generateLeadJSONTest() {
        Lead testLead = [
            Select Id, AccessCode__c, Company, Country, CountryCode, Email, FirstName, TypeOfUse__c, LastName, LeadSource,
                LicenseKeyStatus__c, LrpSid__c, Phone, RemoteIp__c, RestrictedPartyStatus__c, RestrictedPartyStatusDate__c, Title,
                (Select CampaignId, CreatedDate, Campaign.NetsuiteCampaignInternalId__c 
                 From CampaignMembers 
                 Order By CreatedDate DESC 
                 Limit 1)
            From Lead 
            Where LrpSid__c = '1234567890'
            Limit 1];

        Test.startTest();

        NetsuiteService service = new NetsuiteService();
        String lrpJson = service.generateLrpJson(testLead);

        Test.stopTest();

        Map<String, Object> lrpJsonMap = (Map<String, Object>) JSON.deserializeUntyped(lrpJson);
        System.assert(lrpJsonMap.containsKey('lrp'));
        Map<String, Object> lrpDetailsJsonMap = (Map<String, Object>) lrpJsonMap.get('lrp');
        System.assert(lrpDetailsJsonMap.containsKey('email'));
        String email = (String) lrpDetailsJsonMap.get('email');
        System.assertEquals(testLead.Email, email);
        System.assert(lrpDetailsJsonMap.containsKey('lrpsid'));
        String lrpsid = (String) lrpDetailsJsonMap.get('lrpsid');
        System.assertEquals(testLead.LrpSid__c, lrpsid);
        System.assert(lrpDetailsJsonMap.containsKey('leadSource'));
        String leadSource = (String) lrpDetailsJsonMap.get('leadSource');
        System.assertEquals(testLead.CampaignMembers[0].Campaign.NetsuiteCampaignInternalId__c, leadSource);
    }
}