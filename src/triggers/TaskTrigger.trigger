trigger TaskTrigger on Task (
        before insert, after insert,
        before update, after update,
        before delete, after delete, after undelete) {

    // For readability, get a handle on the TriggerService object
    // for this Sobject type
    TriggerService service = TriggerService.getInstance(
            Schema.sobjectType.Task.getName());

    // Process all of the trigger workflows
    service.process(new List<Type> {
        TaskTrackTouchpointWorkflow.class
    });
}