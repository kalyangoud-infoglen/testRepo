trigger CampaignTrigger on Campaign (after insert,before insert,before update,after update,before delete,after delete) 
{
    TriggerService service = TriggerService.getInstance(
            Schema.sobjectType.Campaign.getName());
    
    service.process(new List<Type> {
        CampaignStatusWorkflow.class
    });
}