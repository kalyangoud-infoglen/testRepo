/**
 * This job is responsible for detecting whether there is an existing
 * open lead that is duplicate of the incoming lead, and automatically
 * merging those leads. The new lead is merged into the existing lead;
 * the existing lead survives.
 */
global class LeadMergeJob extends AbstractProfiledAsyncJob {

    /**
     * The list of duplicate record ID sets, where each set is actually a
     * List object with the first element being the surviving record and
     * all subsequent elements being victim records, as is the convention
     * with the `merge` syntax in Apex.
     */
    private List<List<Id>> duplicateIdSets { get; set; }

    /**
     * @param duplicateIdSets The list of duplicate record ID sets
     */
    global LeadMergeJob(List<List<Id>> duplicateIdSets) {
        this.duplicateIdSets = duplicateIdSets;
    }

    /**
     * Kick off the search for a duplicate, and if found, complete the merge
     */
    global override void execute() {
        MergeService.getInstance(
                Schema.SObjectType.Lead.getName()).mergeMany(
                        this.duplicateIdSets);
    }

    global override void finishSuccess() {
        Map<Id,Lead> survivors = new Map<Id,Lead>();

        for (List<Id> eachList : this.duplicateIdSets) {

            // When successful, only the survivor/master record needs
            // to be updated since victim/merged records no longer exist.
            survivors.put(
                    eachList[0],
                    new Lead(Id = eachList[0],
                            MergeJobStatus__c = AsyncJobUtil.SUCCESS_STATUS));
        }

        // If the surviving lead is closed, reopen it (PHX-1610)
        for (Lead eachLead : [
            SELECT 
                Id, 
                ClosedReason__c,
                LastClosedDate__c,
                OwnerId, 
                Status,
                MostRecentCampaign__r.ProductFamily__c,
                PreviousCampaign__r.ProductFamily__c
            FROM Lead 
            WHERE Id IN :survivors.keySet()
        ]) {
            if (eachLead.Status == 'Close') {
                Lead survivor = survivors.get(eachLead.Id);
                survivor.Status = 'Not Started';
                survivor.ClosedReason__c = null;

                if (eachLead.ClosedReason__c == 'Nurture') {
                    survivor.NurtureDetails__c = null;
                }

                //Logic to check whether we should reassign the lead after reopening it
                if (!isOwnerActiveUser(eachLead) || isClosedTooLong(eachLead) || isProductDifferent(eachLead) || (isOwnerActiveUser(eachLead) && !isOwnerQueueMember(eachLead))) {
                    survivor.OwnerId = UserUtil.getQueue('Lead Service Processing').id;
                    survivor.AssignJobStatus__c = AsyncJobUtil.REQUESTED_STATUS;
                }
            }
        }

        update survivors.values();
    }
    /* Modified for PHX-2177*/
    private Boolean isOwnerQueueMember(Lead survivor) {
        Boolean result = false;
        result = LeadUtil.isOwnerQueueMember(survivor.OwnerId);
        return result;
    }
    
    private Boolean isOwnerActiveUser(Lead survivor) {
        Boolean result = true;
        Id ownerId = survivor.OwnerId;

        if (ownerId != null && ownerId.getSobjectType() == Schema.User.getSObjectType()){
            result = [SELECT Id, isActive FROM User WHERE Id = :ownerId].isActive;
        }

        return result;
    }

    private Boolean isClosedTooLong(Lead survivor) {
        Boolean result = false;
        Integer daysThreshold = Integer.valueOf(DaysClosedThreshold__c.getInstance().DaysSinceClosed__c);
        DateTime dateClosed = survivor.LastClosedDate__c;
        if (dateClosed != null ) {
            Integer numOfDays = Date.valueOf(dateClosed).daysBetween(Date.today());
            if (numOfDays > daysThreshold) result = true;
        }

        return result;
    }

    private Boolean isProductDifferent(Lead survivor) {
        Boolean result = false;
        String previousProductFamily = survivor.PreviousCampaign__r.ProductFamily__c;
        String mostRecentProductFamily = survivor.MostRecentCampaign__r.ProductFamily__c;
        
        result = (previousProductFamily != mostRecentProductFamily
                && (previousProductFamily == 'InsightOps' || mostRecentProductFamily == 'InsightOps'));

        return result;
    }

    global override void finishError(System.Exception e) {
        List<Lead> victims = new List<Lead>();

        for (List<Id> eachList : this.duplicateIdSets) {

            // When unsuccessful, we should not touch the survivor/master
            // record since the merge was unsuccessful. Instead we should
            // update all vicitm/merged records that we _wanted_ to merge
            // to indicate that the merge job failed.
            for (Integer i = 1; i < eachList.size(); i++) {
                victims.add(
                        new Lead(
                                Id = eachList[i],
                                MergeJobStatus__c = AsyncJobUtil.ERROR_STATUS));
            }
        }
    }

    /**
     * @see AbstractProfiledAsyncJob
     */
    global override String getClassName() {
        return LeadMergeJob.class.getName();
    }
}