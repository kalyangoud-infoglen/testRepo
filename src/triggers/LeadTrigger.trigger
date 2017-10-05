trigger LeadTrigger on Lead (
        before insert, after insert,
        before update, after update,
        before delete, after delete, after undelete) {

    // For readability, get a handle on the TriggerService object
    // for this Sobject type
    TriggerService service = TriggerService.getInstance(
            Schema.sobjectType.Lead.getName());

    // Process all of the trigger workflows
    service.process(new List<Type> {
        LeadCheckBDROwner.class,
        LeadJunkScrubWorkflow.class,
        LeadJunkScrubAssignWorkflow.class,
        LeadRestrictedPartyWorkflow.class,
        LeadLicenseKeyWorkflow.class,
        LeadMergeWorkflow.class,
        LeadSearchNetsuiteWorkflow.class,
        LeadPreassignWorkflow.class,
        LeadAssignWorkflow.class,
        LeadResolutionWorkflow.class
    });
}