public class Profiler {

    private Map<Id, ProcessEvent__c> processEventsByJobId;
    private Boolean allowCallouts = true;

    public Profiler() {
        processEventsByJobId = new Map<Id, ProcessEvent__c>();        
    }

    public Profiler(Boolean allowCallouts) {
        this.allowCallouts = allowCallouts;
        processEventsByJobId = new Map<Id, ProcessEvent__c>();        
    }

    public void endProfile(Id jobId) {
        ProcessEvent__c event = processEventsByJobId.get(jobId);
        event.EndTime__c = DateTime.now().getTime();

        // If no result was recorded yet, which should only happen
        // in the ERROR case, assume the event finished successfully.
        if (event.Result__c == null) {
            event.Result__c = 'SUCCESS';
        }

        upsert event;
    }
    
    public void interruptProfile(Id jobId, String message) {

        // We only need to update the event parameters and trust that
        // the event will be managed correctly by `endProfile`
        ProcessEvent__c event = processEventsByJobId.get(jobId);
        event.Message__c = message;
        event.Result__c = 'ERROR';
    }

    public void startProfile(Id jobId, AbstractProfiledAsyncJob job) {
        
        // Create a new Process Event record
        ProcessEvent__c event = new ProcessEvent__c(
                EventName__c = jobId,
                ProcessName__c = job.getClassName(),
                ReferenceId__c = null,
                ReferenceName__c = null,
                StartTime__c = DateTime.now().getTime());

        // If callouts are not allowed, go ahead and insert record
        // Otherwise wait until profile ends so uncommitted DML doesn't block callout
        if(!allowCallouts) {
            insert event;
        }

        // Remember the Process Event
        this.processEventsByJobId.put(jobId, event);
    }
}