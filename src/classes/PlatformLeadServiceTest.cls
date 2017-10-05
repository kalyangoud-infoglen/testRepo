@isTest
private class PlatformLeadServiceTest {

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

        // Set the callout mocks
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());

        // Create a lead via the service
        LeadModel bugsModel = new LeadModel();
        bugsModel.lastName = 'Bunny (TEST)';
        bugsModel.company = 'Acme Corporation (TEST)';
        bugsModel.email = 'bugs@acme.test'; 
        bugsModel.leadSource = 'setup';

        LeadService service = new PlatformLeadService();
        service.createLead(bugsModel);

        List<AccessCodeMapping__c> mappings = new List<AccessCodeMapping__c>{
            new AccessCodeMapping__c(
                Name = 'Platform: Test Product 1',
                AccessCode__c = 'ABC',
                AccessCodeProductFamily__c = 'Platform',
                AccessCodeProductName__c = 'Test Product 1'
            ),
            new AccessCodeMapping__c(
                Name = 'Web: Test Product 2',
                AccessCode__c = 'DEF',
                AccessCodeProductFamily__c = 'Web',
                AccessCodeProductName__c = 'Test Product 2'
            )
        };

        insert mappings;
    }

    /**
     * GIVEN ...
     *
     * - an open lead already exists in the system
     * - the LeadMergeWorkflow is active
     * - a merge concern for LeadSource is defined
     *
     * WHEN a duplicate lead is created
     * THEN the duplicate lead should be automatically merged
     */
    @isTest
    private static void createDuplicateLead() {

        // Validate the given
        Lead bugs = [
            SELECT Id,
                Company,
                Email,
                FirstName,
                LastName,
                LeadSource
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals('bugs@acme.test', bugs.Email);
        System.assertEquals('setup', bugs.LeadSource);

        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        LeadModel bugsModel = new LeadModel();
        bugsModel.firstName = 'Bugs';
        bugsModel.lastName = 'Bunny (TEST)';
        bugsModel.company = 'Acme Corporation (TEST)';
        bugsModel.email = 'bugs@acme.test';
        bugsModel.leadSource = 'createDuplicateLead';
        bugsModel.ownerId = UserInfo.getUserId();

        LeadService service = new PlatformLeadService();
        service.createLead(bugsModel);

        // Skip junk scrub
        bugs = [
            SELECT Id
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
            AND LeadSource = 'createDuplicateLead'
        ];

        bugs.JunkScrubStatus__c = AsyncJobUtil.SKIPPED_STATUS;
        bugs.JunkScrubAssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS;

        update bugs;

        // Validate the then
        Test.stopTest();

        List<Lead> records = [
            SELECT Id,
                Company,
                Email,
                FirstName,
                LastName,
                LeadSource
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(1, records.size());
        System.assertEquals('createDuplicateLead', records[0].LeadSource);
    }

    /**
     * GIVEN no duplicate leads exist,
     * WHEN a new lead is submitted for creation with an invalid email 'daffy'
     * using the PlatformLeadService,
     * THEN a ServiceException should be thrown with the message,
     * "Email: invalid email address: daffy"
     */
    @isTest
    private static void failToCreateLead() {

        // Validate the given
        List<Lead> records = [
            SELECT Id,
                Company,
                Email,
                FirstName,
                LastName,
                LeadSource
            FROM Lead
            WHERE LastName = 'Duck (TEST)'
        ];

        System.assertEquals(0, records.size());

        // Do the when
        Test.startTest();

        LeadModel model = new LeadModel();
        model.firstName = 'Daffy';
        model.lastName = 'Duck (TEST)';
        model.company = 'Acme Corporation (TEST)';
        model.email = 'daffy';
        model.leadSource = 'failToCreateLead';

        LeadService service = new PlatformLeadService();

        // Prepare and catch the exception
        ServiceException excepted = null;
        try {
            service.createLead(model);
        }
        catch (ServiceException e) {
            excepted = e;
        }

        // Validate the then
        Test.stopTest();

        System.assertEquals('Email: invalid email address: daffy',
                excepted.getMessage());
    }

    @isTest
    private static void getProductFamilyTest() {
        String found = null;
        String notFound = null;

        Test.startTest();

        PlatformLeadService service = new PlatformLeadService();

        found = service.getProductFamily('DEF');
        notFound = service.getProductFamily('XYZ');

        Test.stopTest();

        System.assertEquals('Web', found);
        System.assertEquals(null, notFound);
    }
}