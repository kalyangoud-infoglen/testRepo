/*Class to check if Lead Owner is present in BDR Queue.*/
public with sharing class LeadCheckBDROwner extends AbstractSobjectWorkflow {

    public LeadCheckBDROwner () {
    }

    public static String marketoEmailId = 'marketo@rapid7.com.ha';
    public override void executeAfter() {
        /* do nothing */
    }
    
    public override void executeBefore() {
        for (Lead leadRecord : (List<Lead>)this.records) {
            if(UserInfo.getUserEmail() == marketoEmailId) {
                leadRecord.IsOwnerBDRQueueMember__c = LeadUtil.isOwnerQueueMember(leadRecord.OwnerID);  
            }
        }
    }

    public override String getClassName() {
        return LeadCheckBDROwner.class.getName();
    }


    public override Boolean qualify(Sobject newRecord, Sobject oldRecord) {
        Boolean qualified = false;
        if (Trigger.isUpdate) {
            qualified = this.qualifyLead((Lead)newRecord,(Lead)oldRecord);
        }
        return qualified;
    }
    
    private Boolean qualifyLead(Lead newRecord,Lead oldRecord) {
        //Boolean qualified = false;
        Boolean qualified;
        //if(newRecord.OwnerId != oldRecord.OwnerId) {
            qualified = true;
        //}
        return qualified;
    }

}