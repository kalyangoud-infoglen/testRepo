public class PlatformLeadService implements LeadService {
    
    public Lead createLead(String firstName, String lastName, String email, String phone, String company, String countryCode, String stateCode, String leadSource, String accessCode, String remoteIp, String language, Boolean consultant, Boolean canadaOptIn, String jobLevel, String title, String typeOfUse, String sourceName, String platformLeadId, Id id) {
        Database.DMLOptions options = new Database.DMLOptions();
        options.DuplicateRuleHeader.allowSave = true;

        String productFamily = getProductFamily(accessCode);

        Lead record = new Lead();
        record.FirstName = firstName;
        record.LastName = lastName;
        record.Email = email;
        record.Phone = phone;
        record.Company = company;
        record.CountryCode = countryCode;
        record.StateCode = stateCode;
        record.LeadSource = leadSource;
        record.AccessCode__c = accessCode;
        record.AccessCodeFamily__c = productFamily;
        record.Language__c = language;
        record.RemoteIp__c = remoteIp;
        record.IsConsultant__c = consultant;
        record.IsCanadaOptIn__c = canadaOptIn;
        record.JobLevel__c = jobLevel;
        record.Title = title;
        record.TypeOfUse__c = typeOfUse;
        record.SourceName__c = sourceName;
        record.PlatformLeadId__c = platformLeadId;
        if(id != null){
            record.ownerId = id;
        }

        // Request junk scrub to be performed on the lead
        record.JunkScrubStatus__c = AsyncJobUtil.REQUESTED_STATUS;
        
        // Create the record
        Database.SaveResult result = Database.insert(record, options);

        // Throw an exception if the operation failed
        if (!result.isSuccess()) {
            throw new ServiceException(result.getErrors()[0].getMessage());
        }

        // Return the created record
        return record;
    }

    /**
     * @param model All of the properties needed to create a lead
     * 
     * @return the created lead
     */
    public Lead createLead(LeadModel model) {
        return this.createLead(
                model.firstName,
                model.lastName,
                model.email,
                model.phone,
                model.company,
                model.countryCode,
                model.stateCode,
                model.leadSource,
                model.accessCode,
                model.remoteIp,
                model.language,
                model.consultant,
                model.canadaOptIn,
                model.jobLevel,
                model.title,
                model.typeOfUse,
                model.sourceName,
                model.platformLeadId,
                model.ownerId);
    }

    public static PlatformLeadService getInstance() {
        return new PlatformLeadService();
    }

    /**
     * Given a list of leads, calculate the appropriate roll-ups
     * for every record, updating the appropriate fields on each one.
     *
     * @param records
     *
     * @return The same records, but with the roll-up values recalculated
     */
    public List<Lead> rollup(List<Lead> records) {
        return this.rollupCampaigns(this.rollupTasks(records));
    }

    public List<Lead> rollupCampaigns(List<Lead> records) {

        // Map query results containing child records
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, (
                SELECT Id, CampaignId, CreatedDate, Campaign.HotLeadCampaign__c
                FROM CampaignMembers
                ORDER BY CreatedDate ASC
            )
            FROM Lead
            WHERE Id IN :records
        ]);

        // Query the database for child campaigns and process each one
        for (Lead eachLead : records) {

            // Grab the campaign history for the lead
            List<CampaignMember> history =
                    leadMap.get(eachLead.Id).CampaignMembers;

            // If the lead has no campaign history, clear out the
            // First and Last Campaign fields. Otherwise grab
            // the first and last campaigns and populate appropriately.
            if (history.isEmpty()) {
                eachLead.FirstCampaign__c = null;
                eachLead.FirstCampaignDateTime__c = null;
                eachLead.MostRecentCampaign__c = null;
                eachLead.MostRecentCampaignDateTime__c = null;
                eachLead.PreviousCampaign__c = null;
                eachLead.HotLeadCampaignRollup__c = false;
            }
            else {
                eachLead.FirstCampaign__c = history[0].CampaignId;
                eachLead.FirstCampaignDateTime__c = history[0].CreatedDate;
                eachLead.MostRecentCampaign__c = history[history.size() - 1].CampaignId;
                eachLead.MostRecentCampaignDateTime__c = history[history.size() - 1].CreatedDate;

                if(history.size() > 1) {
                    eachLead.PreviousCampaign__c = history[history.size() - 2].CampaignId;
                } else {
                    eachLead.PreviousCampaign__c = null;
                }

                Boolean hotLeadCampaignRollup = false;
                for (CampaignMember member : history) {
                    hotLeadCampaignRollup = hotLeadCampaignRollup || member.Campaign.HotLeadCampaign__c;
                }
                eachLead.HotLeadCampaignRollup__c = hotLeadCampaignRollup;
            }
        }

        return records;
    }

    public List<Lead> rollupTasks(List<Lead> records) {

        // Empty the list of touchpoints
        Map<Id, Integer> touchpointsById = new Map<Id, Integer>();
        Map<Id, Integer> currentTouchpointsById = new Map<Id, Integer>();

        // Count the aggregate query results
        for(Lead eachLead : [
            SELECT Id, LastOpenedDate__c, (
                SELECT Id, ActivityDate
                FROM Tasks
                WHERE Status = :TaskUtil.COMPLETED_STATUS
                AND Type IN :TaskUtil.getTouchpointTypeSet()
            )
            FROM Lead
            WHERE Id IN :records
        ]) {
            
            // Convenient local counters
            Integer touchpoints = 0;
            Integer currentTouchpoints = 0;

            // Count the tasks
            for (Task eachTask : eachLead.Tasks) {

                // Always counts as a historical touchpoint
                touchpoints++;

                // Conditionally counts as a current touchpoint
                if (eachTask.ActivityDate >= eachLead.LastOpenedDate__c) {
                    currentTouchpoints++;
                }
            }

            // Remember the counters
            touchpointsById.put(eachLead.Id, touchpoints);
            currentTouchpointsById.put(eachLead.Id, currentTouchpoints);
        }

        // Pop the results on to the given records
        for (Lead eachLead : records) {
            eachLead.NumberOfTouchpoints__c =
                    touchpointsById.get(eachLead.Id);
            eachLead.NumberOfCurrentTouchpoints__c =
                    currentTouchpointsById.get(eachLead.Id);
        }

        return records;
    }
    
    public void createCampaignMember(Id id, String campaignId)
    {
        CampaignMember campaignMember = new CampaignMember();
        campaignMember.leadId = id;
        campaignMember.campaignId = campaignId;
        campaignMember.status = 'Sent';
        insert campaignMember;
    }
    
    public void createLeadKeyRecord(Id id, String platformLeadId){
            LeadKey__c leadKey = new LeadKey__c();
            leadKey.Lead__c = id;
            leadKey.PlatformLeadId__c = platformLeadId;
            insert leadKey;
    }

    @TestVisible
    private String getProductFamily(String accessCode) {
        String productFamily = null;
        Map<String, String> accessCodeToProductFamily = new Map<String, String>();
        
        if (String.isNotBlank(accessCode)) {
            for (AccessCodeMapping__c accessCodeMapping : [
                SELECT AccessCode__c, AccessCodeProductFamily__c
                FROM AccessCodeMapping__c ]) {

                accessCodeToProductFamily.put(
                    accessCodeMapping.AccessCode__c,
                    accessCodeMapping.AccessCodeProductFamily__c
                );
            }

            if (accessCodeToProductFamily.containsKey(accessCode)) {
                productFamily = accessCodeToProductFamily.get(accessCode);
            }
        }

        return productFamily;
    }
    
}