@isTest
public class LeadSearchNetsuiteServiceTest {

    @testSetup
    private static void setup() {

        // Create OAuth credentials
        OauthCredential__c netsuiteCredential = new OauthCredential__c(
                Name = 'LEAD_SEARCH_SERVICE',
                Realm__c = '00000',
                ConsumerKey__c = 'xxxxx',
                ConsumerSecret__c = 'xxxxx',
                Token__c = 'xxxxx',
                TokenSecret__c = 'xxxxx');

        insert new List<OauthCredential__c> { netsuiteCredential };

        // Create NetSuite settings
        NetsuiteSetting__c defaultNetsuiteSetting = new NetsuiteSetting__c(
                BaseUrl__c = 'https://system.sandbox.netsuite.com',
                RestletEndpoint__c = 'https://system.sandbox.netsuite.com',
                LeadSearchScript__c = 'LS2017',
                LeadSearchVendorId__c = 'SF_LEADSEARCH',
                OpportunitySearchScript__c = 'OS2017',
                OpportunitySearchVendorId__c = 'SF_OPPORTUNITYSEARCH',
                LeadResolutionScript__c = 'LR2017',
                LeadResolutionVendorId__c = 'SF_LEADRESOLUTION',
                LeadLicenseKeyScript__c = 'LK2017');

        insert new List<NetsuiteSetting__c> { defaultNetsuiteSetting };
    }
    
    @isTest
    private static void verifyLeadUpdatesForSuccessfulCall() {

        // Validate the given
        Lead newLead = new Lead(
                LastName = 'Test Lead ' , 
                Company = 'Test Company ', 
                JobLevel__c = 'Director', 
                Status = 'In Progress',
                Email = 'jon@chipotle.com'
        );
        insert newLead;
    
        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());

        Test.startTest();
        LeadSearchNetsuiteService service = new LeadSearchNetsuiteService();
        List<Lead> enrichedLeads = service.enrichLeads(new List<Lead> { newLead });

        // Validate the then
        Test.stopTest();
        
        System.assertEquals('20964', enrichedLeads[0].NetsuiteCustomerId__c);
        System.assertEquals('102248051', enrichedLeads[0].NetsuiteContactId__c);
        System.assert(String.isNotBlank(enrichedLeads[0].SearchNetsuiteRequest__c));
        System.assert(String.isNotBlank(enrichedLeads[0].SearchNetsuiteResponse__c));
    } 
    
    @isTest
    private static void verifyLeadEnrichmentForShinya() {

        // Validate the given
        Lead newLead = new Lead(
                LastName = 'Test Lead ' , 
                Company = 'Test Company ', 
                JobLevel__c = 'Director', 
                Status = 'Not Started',
                Email = 'higuma-shinya-r@pref.naganolg.jp');

        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        LeadSearchNetsuiteService service = new LeadSearchNetsuiteService();
        List<Lead> enrichedLeads = service.enrichLeads(new List<Lead> { newLead });

        // Validate the then
        Test.stopTest();
        
        // Validate the then
        System.assertEquals('110281368', enrichedLeads[0].NetsuiteCustomerId__c);
        System.assertEquals('110282269', enrichedLeads[0].NetsuiteContactId__c);
        System.assertEquals('Customer', enrichedLeads[0].CustomerStatus__c);
        System.assertEquals('Kayo Sakai', enrichedLeads[0].Bdr__c);
        System.assertEquals('Gota Kato', enrichedLeads[0].TemAe__c);
    }

    @isTest
    private static void verifyLeadUpdatesForPartialCall() {

        // Validate the given
        Lead newLead = new Lead(
            LastName = 'Test Lead ' , 
            Company = 'Test Company ', 
            JobLevel__c = 'Director', 
            Status = 'In Progress',
            CompanyDunsNumber = '654507094'
        );

        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        LeadSearchNetsuiteService service = new LeadSearchNetsuiteService();
        List<Lead> enrichedLeads = service.enrichLeads(new List<Lead> { newLead });

        // Validate the then
        Test.stopTest();

        System.assertEquals('1067034', enrichedLeads[0].NetsuiteCustomerId__c); 
        System.assertEquals(null, enrichedLeads[0].NetsuiteContactId__c);
    }

    @isTest
    private static void verifyLeadUpdatesForMultipleMatchingContacts() {

        // Validate the given
        Lead newLead = new Lead(
            LastName = 'Test Lead' , 
            Company = 'Test Company', 
            JobLevel__c = 'Director', 
            Status = 'In Progress',
            Email = 'aaron.mixedcase@meadowbrook.com'
        );

        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        LeadSearchNetsuiteService service = new LeadSearchNetsuiteService();
        List<Lead> enrichedLeads = service.enrichLeads(new List<Lead> { newLead });

        // Validate the then
        Test.stopTest();

        System.assertEquals('55397', enrichedLeads[0].NetsuiteCustomerId__c); 
        System.assertEquals('59788307', enrichedLeads[0].NetsuiteContactId__c);
    }
    
    @isTest
    private static void verifyLeadUpdatesForEmptyCall() {

        // Validate the given
        Lead newLead = new Lead(
            LastName = 'Test Lead ' , 
            Company = 'Test Company ', 
            JobLevel__c = 'Director', 
            Status = 'In Progress', 
            Email = 'wayne@bruce.com'
        );

        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        LeadSearchNetsuiteService service = new LeadSearchNetsuiteService();
        List<Lead> enrichedLeads = service.enrichLeads(new List<Lead> { newLead });

        // Validate the then
        Test.stopTest();
        
        System.assertEquals(null, enrichedLeads[0].NetsuiteCustomerId__c);
        System.assertEquals(null, enrichedLeads[0].NetsuiteContactId__c);
    }
}