/**
 * This class provides unit tests for LeadResolutionService
 */
@isTest
private class LeadResolutionServiceTest {

    @testSetup
    static void createTestData() {
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;

        Lead testLead1 = new Lead(
            FirstName = 'Test', 
            LastName = 'Lead1', 
            Street = '123 Any St',
            City = 'Springfield',
            Country = 'United States',
            PostalCode = '12345',
            Description = 'Test lead',
            Title = 'Senior Test', 
            Email = 'test@example.com',
            Phone = '800-555-1212', 
            Company = 'Test Corp', 
            LeadSource = 'Other', 
            LrpSid__c = '1234567890',
            RemoteIp__c = '10.1.1.1',
            Industry = 'Business',
            CompanyDunsNumber = '12345',
            AccessCode__c = '123XYZ',
            InferScore__c = 10.0,
            JobLevel__c = null,
            Status = 'In Progress',
            ClosedReason__c = null,
            NetsuiteContactId__c = null,
            NetsuiteCustomerId__c = null,
            MergeJobStatus__c = 'Skipped',
            SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            RestrictedPartyJobStatus__c = 'Skipped',
            LicenseKeyJobStatus__c = 'Skipped'
        );
        Database.SaveResult result = Database.insert(testLead1, dmlOptions);
        System.assert(result.isSuccess(), 'Test lead insert failed');

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

    // Test the public resolveLeads() method (success)
    @isTest
    static void resolveLeadsSuccessTest() {
        List<Lead> leads = [Select Id From Lead];
        List<Id> leadIds = new List<Id>();
        for(Lead lead : leads) {
            leadIds.add(lead.Id);
        }

        Test.setMock(HttpCalloutMock.class, new LeadResolutionServiceMock());

        Test.startTest();

        LeadResolutionService service = new LeadResolutionService();
        service.resolveLeads(leadIds);

        Test.stopTest();

        Lead testLead = getTestLead('Lead1');
        System.assertEquals(LeadResolutionService.LR_STATUS_SUCCESS, testLead.ResolutionStatus__c, 'Expected Resolution Status to be ' + LeadResolutionService.LR_STATUS_SUCCESS);
        System.assert(testLead.ResolutionStatusDetails__c != null, 'Expected Resolution Status Details field to be not null');
    }

    // Test the public resolveLeads() method (failure)
    @isTest
    static void resolveLeadsFailureTest() {
        List<Lead> leads = [Select Id From Lead];
        List<Id> leadIds = new List<Id>();
        for(Lead lead : leads) {
            leadIds.add(lead.Id);
        }

        Test.setMock(HttpCalloutMock.class, new LeadResolutionServiceMock(400, '{"error" : {"code" : "JS_EXCEPTION", "message" : "ERROR"}}'));

        Test.startTest();

        LeadResolutionService service = new LeadResolutionService();
        service.resolveLeads(leadIds);

        Test.stopTest();

        Lead testLead = getTestLead('Lead1');
        System.assertEquals(LeadResolutionService.LR_STATUS_ERROR, testLead.ResolutionStatus__c, 'Expected Resolution Status to be ' + LeadResolutionService.LR_STATUS_ERROR);
        System.assert(testLead.ResolutionStatusDetails__c != null, 'Expected Resolution Status Details field to be not null');
    }

    // Test a successful lead resolution
    @isTest
    static void resolveLeadSuccessTest() {
        Lead testLead = getTestLead('Lead1');

        Test.setMock(HttpCalloutMock.class, new LeadResolutionServiceMock());

        Test.startTest();

        LeadResolutionService service = new LeadResolutionService();
        LeadResolutionResult result = service.resolveLead(testLead, '123456');

        Test.stopTest();
        
        System.assert(result != null, 'Expected LeadResolutionResult to be not null');
        System.assertEquals(123, result.id, 'LeadResolutionResult.id');
        System.assertEquals('https://system.netsuite.com/app/crm/calendar/task.nl?id=123', result.meta.href, 'LeadResolutionResult.meta.href');
        System.assert(result.account != null, 'Expected Netsuite account to be not null');
        System.assert(result.account.id != null, 'Expected Netsuite account id to be not null');
        System.assert(result.contact != null, 'Expected Netsuite contact to be not null');
        System.assert(result.contact.id != null, 'Expected Netsuite countact id to be not null');
        System.assertEquals(LeadResolutionService.LR_STATUS_SUCCESS, testLead.ResolutionStatus__c, 'Expected Resolution Status to be ' + LeadResolutionService.LR_STATUS_SUCCESS);
        System.assertEquals(result.account.id, testLead.NetsuiteCustomerId__c, 'Expected Netsuite Customer Id on lead to match account id in service result');
        System.assertEquals(result.contact.id, testLead.NetsuiteContactId__c, 'Expected Netsuite Contact Id on lead to match contact id in service result');
        System.assert(testLead.ResolutionStatusDetails__c != null, 'Expected Resolution Status Details field to be not null');
    }

    // Test a failed lead resolution
    @isTest
    static void resolveLeadFailureTest() {
        Lead testLead = getTestLead('Lead1');

        Test.setMock(HttpCalloutMock.class, new LeadResolutionServiceMock(400, '{"error" : {"code" : "JS_EXCEPTION", "message" : "ERROR"}}'));

        Test.startTest();

        LeadResolutionService service = new LeadResolutionService();
        LeadResolutionResult result;
        Exception expectedException;

        try {
            result = service.resolveLead(testLead, '123456');
        }
        catch (Exception ex) {
            expectedException = ex;
        }

        Test.stopTest();
        
        System.assert(result == null, 'Expected LeadResolutionResult to be null');
        System.assert(expectedException != null, 'Expected exception to be not null');
        System.assert(testLead.ResolutionStatus__c == null, 'Expected Resolution Status to be null');
        System.assert(testLead.NetsuiteCustomerId__c == null, 'Expected Netsuite Customer Id on lead to be null');
        System.assert(testLead.NetsuiteContactId__c == null, 'Expected Netsuite Contact Id on lead to be null');
        System.assert(testLead.ResolutionStatusDetails__c == null, 'Expected Resolution Status Details field to be null');
    }

    private static Lead getTestLead(String lastName) {
        Lead testLead = [
            Select Id, City, ClosedReason__c, Company, CompanyDunsNumber, CountryCode, CreatedDate, Description, Email, FirstName, 
                   Industry, InferScore__c, JobLevel__c, LastName, LeadSource, NetsuiteContactId__c, NetsuiteCustomerId__c, 
                   Phone, PostalCode, ResolutionStatus__c, ResolutionStatusDetails__c, StateCode, Status, Street, Title,
                   (Select CampaignId, CreatedDate, Campaign.Name, Campaign.NetsuiteCampaignInternalId__c 
                    From CampaignMembers 
                    Order By CreatedDate DESC 
                    Limit 1)
            From Lead
            Where LastName = :lastName
            Limit 1
        ];
        return testLead;
    }
}