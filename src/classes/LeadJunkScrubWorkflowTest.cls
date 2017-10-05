@isTest
private class LeadJunkScrubWorkflowTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    /**
     * Verify that junk scrub executes correctly for leads that have possible
     * duplicates identified via native duplicate rules.
     *
     * - Given an existing lead;
     * - When a new lead is created via `LeadResource` that would be identified
     *   as a duplicate based on Name and Company, and an Infer score is added
     *   to the lead;
     * - Then junk scrub should still be performed successfully for
     *   the new inbound lead
     *
     * @see PHX-1603
     */
    @isTest
    private static void inboundDuplicate() {

        //Get existing Campaign from the TestUtil class
        Campaign getTvAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'TV Ad (TEST)'
        ];

        // Given
        infer3__Score_Object__c inferScore = new infer3__Score_Object__c(
                infer3__Score_1__c = '000',
                infer3__Score_2__c = '100');

        insert new List<infer3__Score_Object__c> { inferScore };

        Lead existingBugs = [
            SELECT Id, FirstName, LastName, Company, Email, Phone,
                JunkScrubStatus__c
            FROM Lead
            WHERE LastName = 'Bunny (TEST)'
        ];

        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, existingBugs.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        String firstName = existingBugs.FirstName.toLowerCase();
        String lastName = existingBugs.LastName.toLowerCase();
        String email = existingBugs.Email + '.diff';
        String phone = existingBugs.Phone;
        String company = existingBugs.Company.toLowerCase();
        String countryCode = 'US';
        String stateCode = 'AK';
        String leadSource = 'Website';
        String accessCode = null;
        String campaignId = null;
        String remoteIp = '54.225.193.88';
        String language = 'English';
        Boolean consultant = false;
        Boolean canadaOptIn = false;
        String jobLevel = 'Analyst';
        String title = 'Prospector';
        String typeOfUse = 'Personal';
        String sourceName = 'Web';
        String platformLeadId = 'abccd123';

        // Create the lead
        RestContext.response = new RestResponse();  // for LeadResource
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

        // Set the Infer score
        Lead newBugs = [
            SELECT Id
            FROM Lead
            WHERE LastName = 'Bunny (TEST)' AND StateCode = 'AK'
        ];

        CampaignMember newBugsTvAd = new CampaignMember(
            CampaignId = getTvAd.id,
            Leadid = newBugs.id,
            Status = 'Sent'
        );

        Insert newBugsTvAd;

        newBugs.infer3__Score_Index__c = 170;
        newBugs.infer3__Score_Object_ID__c = inferScore.Id;
        update newBugs;

        // Then
        Test.stopTest();

        newBugs = [
            SELECT Id, JunkScrubStatus__c
            FROM Lead
            WHERE Id = :newBugs.Id
        ];

        //This assert will now check that JunkScrub did run and JunkScrubStatus__c
        //is set to SUCCESS; since we created a CampaignMember for the newBugs Lead 
        //Hence CampaignMember does exist and LeadJunkScrubWorkflow.qualify() passes
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, newBugs.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
    }

    /**
     * To avoid repetition of defect PHX-1589, this test is intended to make
     * sure the `Lead.InferScore2__c` formula field works as expected.
     *
     * Given                                               | Then
     * First Name | infer3__Infer_Score__c | InferScore__c | InferScore2__c
     * ---------- | ---------------------- | ------------- | --------------
     * Peter      | null                   | null          | null
     * Tony       | 0                      | null          | 0
     * Steve      | null                   | 0             | 0
     * Stephen    | 100                    | null          | 100
     * Logan      | 100                    | 77            | 77
     * Scott      | null                   | 77            | 77
     */
    @isTest
    private static void inferScore2() {

        // Given
        infer3__Score_Object__c inferScore = new infer3__Score_Object__c(
                infer3__Score_1__c = '000',
                infer3__Score_2__c = '100');

        insert new List<infer3__Score_Object__c> { inferScore };

        Lead peter = new Lead(
                FirstName = 'Peter',
                LastName = 'Parker (TEST)',
                Company = 'Marvel Universe (TEST)',
                InferScore__c = null);

        Lead tony = new Lead(
                FirstName = 'Tony',
                LastName = 'Stark (TEST)',
                Company = 'Marvel Universe (TEST)',
                InferScore__c = null,
                infer3__Score_Index__c = 85,
                infer3__Score_Object_ID__c = inferScore.Id);

        Lead steve = new Lead(
                FirstName = 'Steve',
                LastName = 'Rogers (TEST)',
                Company = 'Marvel Universe (TEST)',
                InferScore__c = 0);

        Lead stephen = new Lead(
                FirstName = 'Stephen',
                LastName = 'Strange (TEST)',
                Company = 'Marvel Universe (TEST)',
                InferScore__c = null,
                infer3__Score_Index__c = 170,
                infer3__Score_Object_ID__c = inferScore.Id);

        Lead logan = new Lead(
                FirstName = 'James',
                LastName = 'Howlett (TEST)',
                Company = 'Marvel Universe (TEST)',
                InferScore__c = 77,
                infer3__Score_Index__c = 170,
                infer3__Score_Object_ID__c = inferScore.Id);

        Lead scott = new Lead(
                FirstName = 'Scott',
                LastName = 'Summers (TEST)',
                Company = 'Marvel Universe (TEST)',
                InferScore__c = 77);

        Map<String, Map<Schema.SObjectField, Decimal>> expectedMap =
                new Map<String, Map<Schema.SObjectField, Decimal>> {
            'Peter Parker (TEST)' => new Map<Schema.SObjectField, Decimal> {
                Schema.Lead.infer3__Infer_Score__c => null,
                Schema.Lead.InferScore__c => null,
                Schema.Lead.InferScore2__c => null
            },
            'Tony Stark (TEST)' => new Map<Schema.SObjectField, Decimal> {
                Schema.Lead.infer3__Infer_Score__c => 0,
                Schema.Lead.InferScore__c => null,
                Schema.Lead.InferScore2__c => 0
            },
            'Steve Rogers (TEST)' => new Map<Schema.SObjectField, Decimal> {
                Schema.Lead.infer3__Infer_Score__c => null,
                Schema.Lead.InferScore__c => 0,
                Schema.Lead.InferScore2__c => 0
            },
            'Stephen Strange (TEST)' => new Map<Schema.SObjectField, Decimal> {
                Schema.Lead.infer3__Infer_Score__c => 100,
                Schema.Lead.InferScore__c => null,
                Schema.Lead.InferScore2__c => 100
            },
            'James Howlett (TEST)' => new Map<Schema.SObjectField, Decimal> {
                Schema.Lead.infer3__Infer_Score__c => 100,
                Schema.Lead.InferScore__c => 77,
                Schema.Lead.InferScore2__c => 77
            },
            'Scott Summers (TEST)' => new Map<Schema.SObjectField, Decimal> {
                Schema.Lead.infer3__Infer_Score__c => null,
                Schema.Lead.InferScore__c => 77,
                Schema.Lead.InferScore2__c => 77
            }
        };

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        insert new List<Lead> { peter, tony, steve, stephen, logan, scott };

        // Then
        Test.stopTest();

        for (String eachName : expectedMap.keySet()) {
            Map<Schema.SObjectField, Decimal> expectedValueMap =
                    expectedMap.get(eachName);

            Lead actualRecord = [
                SELECT Id, InferScore__c, InferScore2__c,
                    infer3__Infer_Score__c
                FROM Lead
                WHERE Name = :eachName
            ];

            for (Schema.SObjectField eachField : expectedValueMap.keySet()) {
                Decimal expected = expectedValueMap.get(eachField);
                Decimal actual = (Decimal)actualRecord.get(eachField);

                System.assertEquals(
                        expected, actual, eachName + ': ' + eachField);
            }
        }
    }

    /**
     * - Given an inbound lead with terrible data quality;
     * - When the lead is created by `PlatformLeadService`;
     * - Then the lead should be auto-junked after Junk Scrub finishes
     */
    @isTest
    private static void failJunkScrub() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead abc = new Lead(
                FirstName = '!@#$',
                LastName = 'b',
                Title = 'Alphabet',
                Company = 'c',
                Phone = '1-800-COLLECT',
                Email = 'bugs@no.mail.server');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                abc.FirstName,             // firstName
                abc.LastName,              // lastName
                abc.Email,                 // email
                abc.Phone,                 // phone
                abc.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                abc.Title,                 // title
                null,                      // typeOfUse
                null,                      //sourceName
                null);                     //platformLeadId

        // Add to a campaign, then make up an Infer score
        abc = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :abc.Email
        ];

        abc.InferScore__c = 6;

        update abc;

        // Then
        Test.stopTest();

        abc = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title
            FROM Lead
            WHERE Email = :abc.Email
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, abc.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);

        System.assertEquals(33.0, abc.DataQualityScore__c,
                Schema.SObjectType.Lead.fields.DataQualityScore__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, abc.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
    }

    /**
     * This test explicitly covers a defect scenario reported during
     * Release 1 hypercare.
     *
     * - Given an inbound lead that Infer would score as a zero;
     * - When the lead is created by `PlatformLeadService`;
     * - Then the lead should be auto-junked after Junk Scrub finishes
     *
     * @see PHX-1645
     */
    @isTest
    private static void failJunkScrubWithInferScoreZero() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead abc = new Lead(
                FirstName = '!@#$',
                LastName = 'b',
                Title = 'Alphabet',
                Company = 'c',
                Phone = '1-800-COLLECT',
                Email = 'bugs@no.mail.server');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                abc.FirstName,             // firstName
                abc.LastName,              // lastName
                abc.Email,                 // email
                abc.Phone,                 // phone
                abc.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                abc.Title,                 // title
                null,                      // typeOfUse
                null,                      // sourceName
                null);                     // platformLeadId

        // Add to a campaign, then make up an Infer score
        abc = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :abc.Email
        ];

        infer3__Score_Object__c inferScore = new infer3__Score_Object__c(
                infer3__Score_1__c = '000',
                infer3__Score_2__c = '100');

        insert inferScore;

        abc.infer3__Score_Object_ID__c = inferScore.Id;
        abc.infer3__Score_Index__c = 85;

        update abc;

        // Then
        Test.stopTest();

        abc = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                InferScore2__c,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                infer3__Infer_Score__c
            FROM Lead
            WHERE Email = :abc.Email
        ];

        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, abc.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);

        System.assertEquals(0.0, abc.infer3__Infer_Score__c,
                Schema.SObjectType.Lead.fields.infer3__Infer_Score__c.label);
        System.assertEquals(0.0, abc.InferScore2__c,
                Schema.SObjectType.Lead.fields.InferScore2__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, abc.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
    }

    /**
     * - Given an inbound lead with great data quality;
     * - When the lead is created by `PlatformLeadService`;
     * - Then the lead should _not_ be auto-junked
     */
    @isTest
    private static void passJunkScrub() {
        //Adding this to satisfy criteria in LeadJunkScrubWorkflow.qualify()
        //that Leads must have Campaign(s) associated with them 

        Campaign getTvAd = [
            SELECT id
            FROM Campaign
            WHERE Name = 'TV Ad (TEST)'

        ];

        // Given
        Lead foghorn = new Lead(
                FirstName = 'Foghorn',
                LastName = 'Leghorn (TEST)',
                Title = 'Rooster',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-316-5400',
                Email = 'foghorn@acme.test');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        LeadModel model = new LeadModel();
        model.firstName = foghorn.FirstName;
        model.lastName = foghorn.LastName;
        model.title = foghorn.Title;
        model.company = foghorn.Company;
        model.phone = foghorn.Phone;
        model.email = foghorn.Email;

        // Create the lead
        new PlatformLeadService().createLead(model);

        // Make up an Infer score
        foghorn = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :foghorn.Email
        ];

        foghorn.InferScore__c = 30;

        update foghorn;

        CampaignMember foghornCampaign = new CampaignMember (
            Leadid = foghorn.id,
            CampaignId = getTvAd.id
        );

        insert foghornCampaign;
        // Then
        Test.stopTest();

        foghorn = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                MostRecentCampaign__c
            FROM Lead
            WHERE Email = :foghorn.Email
        ];

        foghornCampaign = [
            SELECT Id, CampaignId
            FROM CampaignMember
            WHERE Leadid = :foghorn.id
        ];

        System.assertEquals(foghornCampaign.CampaignId, foghorn.MostRecentCampaign__c);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, foghorn.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(83.0, foghorn.DataQualityScore__c,
                Schema.SObjectType.Lead.fields.DataQualityScore__c.label);
        System.assertNotEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, foghorn.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
    }

    /**
     * - Given an inbound lead with great data quality;
     * - When the lead is created by `PlatformLeadService`;
     * - Then the lead should _not_ be auto-junked
     */
    @isTest
    private static void passJunkScrubWithImperfectScore() {
        //Adding this to satisfy criteria in LeadJunkScrubWorkflow.qualify()
        //that Leads must have Campaign(s) associated with them 

        Campaign getTvAd = [
            SELECT id
            FROM Campaign
            WHERE Name = 'TV Ad (TEST)'

        ];
        // Given
        Lead foghorn = new Lead(
                FirstName = 'Fh',
                LastName = 'Leghorn (TEST)',
                Title = 'Rooster',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-316-5400',
                Email = 'foghorn@acme.test');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        LeadModel model = new LeadModel();
        model.firstName = foghorn.FirstName;
        model.lastName = foghorn.LastName;
        model.title = foghorn.Title;
        model.company = foghorn.Company;
        model.phone = foghorn.Phone;
        model.email = foghorn.Email;

        // Create the lead
        new PlatformLeadService().createLead(model);

        // Make up an Infer score
        foghorn = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :foghorn.Email
        ];

        foghorn.InferScore__c = 30;

        update foghorn;

        CampaignMember foghornCampaign = new CampaignMember (
            Leadid = foghorn.id,
            CampaignId = getTvAd.id
        );

        insert foghornCampaign;
        // Then
        Test.stopTest();

        foghorn = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                MostRecentCampaign__c
            FROM Lead
            WHERE Email = :foghorn.Email
        ];

        foghornCampaign = [
            SELECT Id, CampaignId
            FROM CampaignMember
            WHERE Leadid = :foghorn.id
        ];

        System.assertEquals(foghornCampaign.CampaignId, foghorn.MostRecentCampaign__c);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, foghorn.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(78.0, foghorn.DataQualityScore__c,
                Schema.SObjectType.Lead.fields.DataQualityScore__c.label);
        System.assertNotEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, foghorn.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
    }

    /**
     * - Given good data for a lead to be manually created
     * - When the lead is manually created (i.e., plain `insert`)
     * - Then Junk Scrub Job Status should be set to "Skipped"
     */
    @isTest
    private static void skipJunkScrub() {
        
        // Given
        Lead foghorn = new Lead(
                FirstName = 'Foghorn',
                LastName = 'Leghorn (TEST)',
                Title = 'Rooster',
                Company = 'Acme Corporation (TEST)',
                Phone = '617-316-5400',
                Email = 'foghorn@acme.test');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        insert foghorn;

        // Then
        Test.stopTest();

        foghorn = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title
            FROM Lead
            WHERE Email = :foghorn.Email
        ];

        System.assertEquals(AsyncJobUtil.SKIPPED_STATUS, foghorn.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);

        System.assertEquals(0, foghorn.DataQualityScore__c,
                Schema.SObjectType.Lead.fields.DataQualityScore__c.label);
        System.assertEquals(UserInfo.getUserId(), foghorn.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
    }

    /**
     * - Given an inbound lead with terrible data quality; First Name is in the 
     * - list of restrickted strings; 
     * - When the lead is created by `PlatformLeadService`;
     * - Then the lead should be auto-junked after Junk Scrub finishes
     * - JunkedReason__c field should display an error for First Name being rejected
     */
    @isTest
    private static void failFirstNameValidation() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead hacker = new Lead(
                FirstName = 'hack3r',
                LastName = 'b',
                Title = 'Alphabet',
                Company = 'c',
                Phone = '888-888-1234',
                Email = 'bugs@no.mail.server');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                hacker.FirstName,             // firstName
                hacker.LastName,              // lastName
                hacker.Email,                 // email
                hacker.Phone,                 // phone
                hacker.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                hacker.Title,                 // title
                null,                        // typeOfUse
                null,                       //sourceName
                null);                      // platformLeadId

        // Add to a campaign, then make up an Infer score
        hacker = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        hacker.InferScore__c = 66;

        update hacker;

        // Then
        Test.stopTest();

        hacker = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                JunkedReason__c,
                Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals('Close', hacker.Status);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, hacker.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, hacker.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
        System.assertEquals('NameBlacklistCheck class failed', hacker.JunkedReason__c);
    }

    @isTest
    private static void failLastNameValidation() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead hacker = new Lead(
                FirstName = 'art',
                LastName = 'hack3r',
                Title = 'Alphabet',
                Company = 'c',
                Phone = '888-8888',
                Email = 'bugs@no.mail.server');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                hacker.FirstName,             // firstName
                hacker.LastName,              // lastName
                hacker.Email,                 // email
                hacker.Phone,                 // phone
                hacker.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                hacker.Title,                 // title
                null,                         // typeOfUse
                null,                       //sourceName
                null);                     // platformLeadId

        // Add to a campaign, then make up an Infer score
        hacker = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        hacker.InferScore__c = 66;

        update hacker;

        // Then
        Test.stopTest();

        hacker = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                JunkedReason__c,
                Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals('Close', hacker.Status);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, hacker.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, hacker.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
        System.assertEquals('NameBlacklistCheck class failed', hacker.JunkedReason__c);
    }

    @isTest
    private static void failTitleNameValidation() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead hacker = new Lead(
                FirstName = 'arte',
                LastName = 'b',
                Title = 'hack3r',
                Company = 'c',
                Phone = '888-8888',
                Email = 'bugs@no.mail.server');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                hacker.FirstName,             // firstName
                hacker.LastName,              // lastName
                hacker.Email,                 // email
                hacker.Phone,                 // phone
                hacker.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                hacker.Title,                 // title
                null,                        // typeOfUse
                null,                        // sourceName
                null);                      //platformLeadId

        // Add to a campaign, then make up an Infer score
        hacker = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        hacker.InferScore__c = 66;

        update hacker;

        // Then
        Test.stopTest();

        hacker = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                JunkedReason__c,
                Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals('Close', hacker.Status);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, hacker.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, hacker.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
        System.assertEquals('TitleBlacklistCheck class failed', hacker.JunkedReason__c);
    }

    @isTest
    private static void failEmailValidation() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead hacker = new Lead(
                FirstName = 'artem',
                LastName = 'bee',
                Title = 'Google',
                Company = 'company',
                Phone = '6173859235',
                Email = '104903@020.co.uk');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                hacker.FirstName,             // firstName
                hacker.LastName,              // lastName
                hacker.Email,                 // email
                hacker.Phone,                 // phone
                hacker.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                hacker.Title,                 // title
                null,                        // typeOfUse
                null,                        // sourceName
                null);                      // platformLeadId

        // Add to a campaign, then make up an Infer score
        hacker = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        hacker.InferScore__c = 66;

        update hacker;

        // Then
        Test.stopTest();

        hacker = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                JunkedReason__c,
                Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, hacker.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, hacker.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
        System.assertEquals('DomainBlacklistCheck class failed', hacker.JunkedReason__c);
    }

    @isTest
    private static void failCompanyNameValidation() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead hacker = new Lead(
                FirstName = 'art',
                LastName = 'b',
                Title = 'Alphabet',
                Company = 'hack3r',
                Phone = '888-8888',
                Email = 'bugs@no.mail.server');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                hacker.FirstName,             // firstName
                hacker.LastName,              // lastName
                hacker.Email,                 // email
                hacker.Phone,                 // phone
                hacker.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                hacker.Title,                 // title
                null,                         // typeOfUse
                null,                         // sourceName
                null);                        // platformLeadId

        // Add to a campaign, then make up an Infer score
        hacker = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        hacker.InferScore__c = 66;

        update hacker;

        // Then
        Test.stopTest();

        hacker = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                JunkedReason__c,
                Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals('Close', hacker.Status);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, hacker.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, hacker.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
        System.assertEquals('CompanyNameBlacklistCheck class failed', hacker.JunkedReason__c);
    }

    @isTest
    private static void failPhoneValidation() {
        
        // Given
        Campaign radioAd = [
            SELECT Id
            FROM Campaign
            WHERE Name = 'Radio Ad (TEST)'
        ];

        Lead hacker = new Lead(
                FirstName = 'artem',
                LastName = 'b',
                Title = 'Alphabet',
                Company = 'c',
                Phone = '(000) 000-0000',
                Email = 'bugs@no.mail.server');

        // When
        Test.setMock(HttpCalloutMock.class, new LeadWorkflowMockSuite());
        Test.startTest();

        // Create the lead
        RestContext.response = new RestResponse();
        LeadResource.doPost(
                hacker.FirstName,             // firstName
                hacker.LastName,              // lastName
                hacker.Email,                 // email
                hacker.Phone,                 // phone
                hacker.Company,               // company
                null,                      // countryCode
                null,                      // stateCode
                null,                      // leadSource
                null,                      // accessCode
                radioAd.Id,                // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                null,                      // jobLevel
                hacker.Title,                 // title
                null,                        // typeOfUse
                null,                        // sourceName
                null);                       // platformLeadId

        // Add to a campaign, then make up an Infer score
        hacker = [
            SELECT Id, Email
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        hacker.InferScore__c = 66;

        update hacker;

        // Then
        Test.stopTest();

        hacker = [
            SELECT Id,
                Company,
                DataQualityScore__c,
                Email,
                FirstName,
                JunkScrubStatus__c,
                LastName,
                OwnerId,
                Phone,
                Title,
                JunkedReason__c,
                Status
            FROM Lead
            WHERE Email = :hacker.Email
        ];

        System.assertEquals('Close', hacker.Status);
        System.assertEquals(AsyncJobUtil.SUCCESS_STATUS, hacker.JunkScrubStatus__c,
                Schema.SObjectType.Lead.fields.JunkScrubStatus__c.label);
        System.assertEquals(UserUtil.getQueue(UserUtil.AUTOCLOSED_QUEUE).Id, hacker.OwnerId,
                Schema.SObjectType.Lead.fields.OwnerId.label);
        System.assertEquals('PhoneNumberBlacklistCheck class failed', hacker.JunkedReason__c);
    }
}