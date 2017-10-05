@RestResource(urlMapping='/lead/*')
global with sharing class LeadResource {

    @HttpPost
    global static void doPost(String firstName, String lastName, String email, String phone, String company, String countryCode, String stateCode, String leadSource, String accessCode, String campaignId, String remoteIp, String language, Boolean consultant, Boolean canadaOptIn, String jobLevel, String title, String typeOfUse, String sourceName, String platformLeadId) {
        
        LeadService leadService = new PlatformLeadService();
        
        List<Group> g = [
        	SELECT Id
        	FROM Group
        	WHERE Type = 'Queue' AND DeveloperName = 'JunkScrub'
        ];

        Id id = g.isEmpty() ? null : g[0].Id;
        Lead lead = leadService.createLead(firstName, lastName, email, phone, company, countryCode, stateCode, leadSource, accessCode, remoteIp, language, consultant, canadaOptIn, jobLevel, title, typeOfUse, sourceName, platformLeadId, id);
        
        //On lead creation, create a campaign member recod
        if (lead.id != null && campaignId != null){
            leadService.createCampaignMember(lead.id,campaignId);
        }
        
        //On lead creation, create a lead key record
        if(lead.id != null && platformLeadId != null){
            leadService.createLeadKeyRecord(lead.id, platformLeadId);
        }
        
        RestResponse response = RestContext.response;
        response.addHeader('Location', URL.getSalesforceBaseUrl().toExternalForm() + '/lead/' + lead.id);
        response.addHeader('Content-Type','application/json');
        response.statusCode = 201;
        response.responseBody = Blob.valueOf(JSON.serialize(lead));
    }
    
    @HttpPut
    global static void doPut(String firstName, String lastName, String email, String phone, String company, String countryCode, String stateCode, String leadSource, String accessCode, String campaignId, String remoteIp, String language, Boolean consultant, Boolean canadaOptIn, String jobLevel, String title, String typeOfUse, String sourceName, String platformLeadId, String customerId, String orgId, String correlationId, String pageUrl, String region) {
        
        LeadService leadService = new PlatformLeadService();
        List<LeadKey__c> keyList = new List<LeadKey__c>();
        RegistrationEvent__c regEvent = new RegistrationEvent__c();
        PlatformRegistrationResponse platformRes = new PlatformRegistrationResponse();
        
        if (platformLeadId != null){
        keyList = [
             SELECT Lead__c
             FROM LeadKey__c
             WHERE PlatformLeadId__c = :platformLeadId
            ];
        }
        
        Id id = keyList.isEmpty() ? null : keyList[0].Lead__c;
        
        // If platformLeadId exists for a particular Lead then add the registration event.
        if(id != null){
                regEvent.Lead_c__c = id;
                regEvent.PlatformLeadId__c = platformLeadId;
                regEvent.CustomerId__c = customerId;
                regEvent.OrgId__c = orgId;
                regEvent.CorrelationId__c = correlationId;
                regEvent.PlatformUrl__c = pageUrl;
                regEvent.Region__c = region;
                insert regEvent;
            }
            
        //If Platform Lead does not exist, then create the lead record in the else loop
        else{
                
               List<Group> queueList = [
                	SELECT Id
                	FROM Group
                	WHERE Type = 'Queue' AND DeveloperName = 'JunkScrub'
                ];
        
                Id queueId = queueList.isEmpty() ? null : queueList[0].Id;
                Lead lead = leadService.createLead(firstName, lastName, email, phone, company, countryCode, stateCode, leadSource, accessCode, remoteIp, language, consultant, canadaOptIn, jobLevel, title, typeOfUse, sourceName, platformLeadId, queueId);
                
                //On lead creation, create a campaign member record
                if (lead.id != null && campaignId != null){
                    leadService.createCampaignMember(lead.id,campaignId);
                }
                
                //On lead creation, create a lead key record
                if(lead.id != null && platformLeadId != null){
                  leadService.createLeadKeyRecord(lead.id, platformLeadId);
                }
                 
                //Create a registration event            
                regEvent.Lead_c__c = lead.id;
                regEvent.PlatformLeadId__c = platformLeadId;
                regEvent.CustomerId__c = customerId;
                regEvent.OrgId__c = orgId;
                regEvent.CorrelationId__c = correlationId;
                regEvent.PlatformUrl__c = pageUrl;
                regEvent.Region__c = region;
                insert regEvent;
           }
           
             if (platformLeadId != null){
                keyList = [
                     SELECT Lead__c
                     FROM LeadKey__c
                     WHERE PlatformLeadId__c = :platformLeadId
                    ];
                }
        
            Id leadId = keyList.isEmpty() ? null : keyList[0].Lead__c;
            
            List <Lead> leadInfo = [SELECT FirstName, LastName, Email, Phone, Company, CountryCode, StateCode, LeadSource, AccessCode__c, RemoteIp__c, Language__c, IsConsultant__c, IsCanadaOptIn__c, JobLevel__c, Title, SourceName__c, PlatformLeadId__c FROM Lead where Id = :leadId];
            Lead currentLead = leadInfo.isEmpty() ? null : leadInfo[0];
            
            if(currentLead != null)
            {
                Attributes attribute = new Attributes();
                platformRes.id = leadId;
                attribute.type = 'Lead';
                attribute.url = '/services/data/v40.0/sobjects/lead/'+ leadId;
                platformRes.attributes = attribute;
                platformRes.firstName =currentLead.FirstName;
                platformRes.lastName = currentLead.LastName;
                platformRes.email = currentLead.Email;
                platformRes.phone = currentLead.Phone;
                platformRes.company = currentLead.Company;
                platformRes.countryCode = currentLead.CountryCode;
                platformRes.stateCode = currentLead.StateCode;
                platformRes.leadSource = currentLead.LeadSource;
                
                platformRes.accessCode = currentLead.AccessCode__c;
                platformRes.campaignId = campaignId;
                platformRes.remoteIp = currentLead.RemoteIp__c;
                platformRes.language = currentLead.Language__c;
                platformRes.consultant = currentLead.IsConsultant__c;
                platformRes.canadaOptIn = currentLead.IsCanadaOptIn__c;
                
                platformRes.jobLevel = currentLead.JobLevel__c;
                platformRes.title = currentLead.Title;
                platformRes.sourceName = currentLead.SourceName__c;
                platformRes.platformLeadId = currentLead.PlatformLeadId__c;
                platformRes.customerId = customerId;
                platformRes.orgId = orgId;
                platformRes.correlationId = correlationId;
                platformRes.pageUrl = pageUrl;
                platformRes.region = region;

            }
        
            RestResponse response = RestContext.response;
            response.addHeader('Location', URL.getSalesforceBaseUrl().toExternalForm() + '/lead/' + leadId);
            response.addHeader('Content-Type','application/json');
            response.statusCode = 201;
            response.responseBody = Blob.valueOf(JSON.serialize(platformRes));
        }
}