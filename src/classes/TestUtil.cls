public class TestUtil {

    /**
     * Create standard test data useful for multiple tests
     */
    public static void setup() {
        
        // Create glossary entries
        List<GlossaryEntry__c> entries = new List<GlossaryEntry__c>();

        for (String eachString : new List<String> {
            'poop',
            'fudge',
            'heck'
        }) {
            entries.add(new GlossaryEntry__c(
                    Name = eachString, IsSwear__c = true, isRestricted__c = false));
        }

        insert entries;

        // Create glossary restricted entries
        List<GlossaryEntry__c> restricted = new List<GlossaryEntry__c>();

        for (String eachString : new List<String> {
            'hack3r'
        }) {
            restricted.add(new GlossaryEntry__c(
                    Name = eachString, isRestricted__c = true, IsSwear__c =false));
        }

        insert restricted;

        // Create restricted phone number entries
        List<PhoneNumbers__c> phones = new List<PhoneNumbers__c>();

        for (String eachString : new List<String> {
            '(000) 000-0000'
        }) {
            phones.add(new PhoneNumbers__c(
                    Name = eachString, isInvalid__c = true, isRegex__c = false));
        }

        insert phones;

        // Create restricted phone number entries
        List<PhoneNumbers__c> phoneRegex = new List<PhoneNumbers__c>();

        for (String eachString : new List<String> {
            '^\\d{3}[5]{3,}'
        }) {
            phoneRegex.add(new PhoneNumbers__c(
                    Name = eachString, isInvalid__c = false, isRegex__c = true));
        }

        insert phoneRegex;

        // Create restricted email address entries
        List<EmailDomain__c> spoofEmail = new List<EmailDomain__c>();

        for (String eachString : new List<String> {
            '020.co.uk'
        }) {
            spoofEmail.add(new EmailDomain__c(
                    Name = eachString, BadEmail__c = false,  BadDomain__c = true));
        }

        insert spoofEmail;

        // Create NetSuite settings

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

        // Create credential
        OauthCredential__c leadSearchCredential = new OauthCredential__c(
            Name = 'LEAD_SEARCH_SERVICE',
            Realm__c = 'Test',
            ConsumerKey__c = 'Test',
            ConsumerSecret__c = 'Test',
            Token__c = 'Test',
            TokenSecret__c = 'Test'
        );

        insert new List<OauthCredential__c> { leadSearchCredential };

        // Create campaigns
        Campaign newspaperAd = new Campaign(
                Name = 'Newspaper Ad (TEST)',
                StartDate = Date.today().addDays(-21));

        Campaign billboardAd = new Campaign(
                Name = 'Billboard Ad (TEST)',
                StartDate = Date.today().addDays(-14));

        Campaign radioAd = new Campaign(
                Name = 'Radio Ad (TEST)',
                StartDate = Date.today().addDays(-7));

        Campaign tvAd = new Campaign(
                Name = 'TV Ad (TEST)',
                StartDate = Date.today());

        insert new List<Campaign> { newspaperAd, billboardAd, radioAd , tvAd };

        // Create leads
        Lead bugs = new Lead(
                FirstName = 'Bugs',
                LastName = 'Bunny (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'bugs@acme.test',
                CountryCode = null,
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead daffy = new Lead(
                FirstName = 'Daffy',
                LastName = 'Duck (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'daffy@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead elmer = new Lead(
                FirstName = 'Elmer',
                LastName = 'Fudd (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'elmer@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead tweety = new Lead(
                FirstName = 'Tweety',
                LastName = 'Bird (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'tweety@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead tas = new Lead(
                FirstName = 'Tasmanian',
                LastName = 'Devil (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'tas@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead sylvester = new Lead(
                FirstName = 'Sylvester',
                LastName = 'Pussycat (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'sylvester@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead porky = new Lead(
                FirstName = 'Porky',
                LastName = 'Pig (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'porky@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead marvin = new Lead(
                FirstName = 'Marvin',
                LastName = 'the Martian (TEST)',
                Company = 'Acme Corporation (TEST)',
                Email = 'marvin@acme.test',
                SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS);

        Lead testLead1 = new Lead(
            LastName = 'Test1 (TEST)', Email = 'test@example.com', LeadSource = null,
            Status = 'Not Started', Company = 'Test Corp A (TEST)',
            RestrictedPartyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            LicenseKeyJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            MergeJobStatus__c = AsyncJobUtil.NOT_STARTED_STATUS,
            SearchNetsuiteJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            AssignJobStatus__c = AsyncJobUtil.SKIPPED_STATUS,
            ResolutionJobStatus__c = AsyncJobUtil.SKIPPED_STATUS
            );

        
        
        List<Lead> leads = new List<Lead> {
            bugs,
            daffy,
            elmer,
            tweety,
            tas,
            sylvester,
            porky,
            marvin,
            testLead1
        };

        insert leads;

        Test.setCreatedDate(testLead1.Id, Datetime.now().addDays(-1));

        // Tweak the Last Opened Date on the leads
        for (Lead eachLead : leads) {
            eachLead.LastOpenedDate__c = Date.today().addDays(-2);
        }

        update leads;

        // Try creating leads from web form
        RestContext.response = new RestResponse();  // for LeadResource

        String firstName = 'Wile';
        String lastName = 'Coyote (TEST)';
        String email = 'wile@acme.test';
        String phone = '800-BUY-ACME';
        String company = 'Acme Corporation (TEST)';
        String countryCode = 'US';
        String stateCode = 'CO';
        String leadSource = 'Website';
        String accessCode = null;
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

        // See PHX-1601 for rationale to create lead sa follows
        LeadResource.doPost(
                'Marshall',                // firstName
                'Mathers (TEST)',          // lastName
                'marshall@eminem.test',    // email
                null,                      // phone
                'Eminem (TEST)',           // company
                null,                      // countryCode
                null,                      // stateCode
                'Website',                 // leadSource
                null,                      // accessCode
                null,                      // campaignId
                null,                      // remoteIp
                null,                      // language
                false,                     // consultant
                false,                     // canadaOptIn
                'Analyst',                 // jobLevel
                null,                      // title
                null,                      // typeOfUse
                null,                      // sourceName
                null);                     // platformLeadId

        // Create tasks
        Task daffyFirstOpenTouchpoint = new Task(
                WhoId = daffy.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        Task elmerFirstClosedTouchpoint = new Task(
                WhoId = elmer.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task tweetyFirstClosedTouchpoint = new Task(
                WhoId = tweety.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task tweetySecondOpenTouchpoint = new Task(
                WhoId = tweety.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        Task tasHistoricClosedTouchpoint = new Task(
                WhoId = tas.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task sylvesterHistoricClosedTouchpoint = new Task(
                WhoId = sylvester.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task sylvesterFirstOpenTouchpoint = new Task(
                WhoId = sylvester.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        Task porkyHistoricClosedTouchpoint = new Task(
                WhoId = porky.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task porkyFirstClosedTouchpoint = new Task(
                WhoId = porky.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task marvinHistoricClosedTouchpoint = new Task(
                WhoId = marvin.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-7),
                Status = TaskUtil.COMPLETED_STATUS);

        Task marvinFirstClosedTouchpoint = new Task(
                WhoId = marvin.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today().addDays(-1),
                Status = TaskUtil.COMPLETED_STATUS);

        Task marvinSecondOpenTouchpoint = new Task(
                WhoId = marvin.Id,
                Subject = 'Call (TEST)',
                Type = 'Call',
                ActivityDate = Date.today(),
                Status = TaskUtil.OPEN_STATUS);

        insert new List<Task> {
            daffyFirstOpenTouchpoint,
            elmerFirstClosedTouchpoint,
            tweetyFirstClosedTouchpoint,
            tweetySecondOpenTouchpoint,
            tasHistoricClosedTouchpoint,
            sylvesterHistoricClosedTouchpoint,
            sylvesterFirstOpenTouchpoint,
            porkyHistoricClosedTouchpoint,
            porkyFirstClosedTouchpoint,
            marvinHistoricClosedTouchpoint,
            marvinFirstClosedTouchpoint,
            marvinSecondOpenTouchpoint
        };
    }
}