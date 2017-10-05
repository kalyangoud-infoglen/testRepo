@isTest
private class LeadResourceTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    /**
     * Use `doPost` to create a lead
     */
    @isTest
    private static void doPost() {

        // Validate the given
        Campaign radioAd = [
            SELECT Id, Name
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        List<Lead> existingLeads = [
            SELECT Id
            FROM Lead
            WHERE Email = 'yosemite.sam@acme.test'
        ];

        System.assertEquals(0, existingLeads.size(),
                'No duplicate leads by email should exist');

        // Do the when
        Test.startTest();

        String firstName = 'Yosemite';
        String lastName = 'Sam (TEST)';
        String email = 'yosemite.sam@acme.test';
        String phone = '800-BUY-ACME';
        String company = 'Acme Corporation (TEST)';
        String countryCode = 'US';
        String stateCode = 'CO';
        String leadSource = 'Freemium';
        String accessCode = 'METAPRO';
        String campaignId = radioAd.Id;
        String remoteIp = '54.225.193.88';
        String language = 'English';
        Boolean consultant = false;
        Boolean canadaOptIn = false;
        String jobLevel = 'Analyst';
        String title = 'Prospector';
        String typeOfUse = 'Personal';
        String sourceName = 'Web';
        String platformLeadId = 'abccd123';

        // Stage the REST response
        RestContext.response = new RestResponse();

        LeadResource.doPost(
                firstName,
                lastName,
                email,
                phone,
                company,
                countryCode,
                stateCode,
                leadSource,
                accessCode,
                campaignId,
                remoteIp,
                language,
                consultant,
                canadaOptIn,
                jobLevel,
                title,
                typeOfUse,
                sourceName,
                platformLeadId);

        // Validate the then
        Test.stopTest();

        Lead yosemite = [
            SELECT Id, Email,
                (
                    SELECT Id, CampaignId
                    FROM CampaignMembers
                )
            FROM Lead
            WHERE LastName = 'Sam (TEST)'
        ];

        System.assertEquals('yosemite.sam@acme.test', yosemite.Email,
                Schema.SObjectType.Lead.fields.Email.label);
        System.assertEquals(1, yosemite.CampaignMembers.size(),
                'Campaign History Size');
        System.assertEquals(radioAd.Id, yosemite.CampaignMembers[0].CampaignId,
                'Campaign History should include ' + radioAd.Name);
    }
    
    /**
     * Use `doPut` to create a registration event 
     */
    @isTest
    private static void doPut() {
        
        // Validate the given
        Campaign radioAd = [
            SELECT Id, Name
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];
        
        // Do the when
        Test.startTest();

        String firstName = 'Yosemite';
        String lastName = 'Sam (TEST)';
        String email = 'yosemite.sam@acme.test';
        String phone = '800-BUY-ACME';
        String company = 'Acme Corporation (TEST)';
        String countryCode = 'US';
        String stateCode = 'CO';
        String leadSource = 'Freemium';
        String accessCode = 'METAPRO';
        String campaignId = radioAd.Id;
        String remoteIp = '54.225.193.88';
        String language = 'English';
        Boolean consultant = false;
        Boolean canadaOptIn = false;
        String jobLevel = 'Analyst';
        String title = 'Prospector';
        String typeOfUse = 'Personal';
        String sourceName = 'Web';
        String platformLeadId = 'c878d453-ed86-4b4a-af47-2160ba6f7c5f';
        String customerId = 'cust1234';
        String orgId = 'org1234';
        String correlationId ='cor1234';
        String pageUrl = 'www.rapid7.com/iappsec';
        String region = 'US';

        // Stage the REST response
        RestContext.response = new RestResponse();

        LeadResource.doPut(
                firstName,
                lastName,
                email,
                phone,
                company,
                countryCode,
                stateCode,
                leadSource,
                accessCode,
                campaignId,
                remoteIp,
                language,
                consultant,
                canadaOptIn,
                jobLevel,
                title,
                typeOfUse,
                sourceName,
                platformLeadId,
                customerId,
                orgId,
                correlationId,
                pageUrl,
                region);

        // Validate the then
        Test.stopTest();

        List<Lead> leadInfo = [
            SELECT Id, Email
            FROM Lead
            WHERE PlatformLeadId__c = 'c878d453-ed86-4b4a-af47-2160ba6f7c5f'
        ];

        System.assertEquals(leadInfo[0].Email,'yosemite.sam@acme.test');
        
         List<RegistrationEvent__c> registration = [
            SELECT CustomerId__c
            FROM RegistrationEvent__c
            WHERE PlatformLeadId__c = 'c878d453-ed86-4b4a-af47-2160ba6f7c5f'
        ];
        System.assertEquals(registration[0].CustomerId__c,'cust1234');
        
         List<LeadKey__c> leadKey = [
            SELECT PlatformLeadId__c
            FROM LeadKey__c
            WHERE PlatformLeadId__c = 'c878d453-ed86-4b4a-af47-2160ba6f7c5f'
        ];
        
        System.assertNotEquals(leadKey.isEmpty(),true);
        
    }
}