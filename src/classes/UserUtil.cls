public with sharing class UserUtil {

    /**
     * The queue to which junk leads are expected to be automatically assigned
     */
    public static final String AUTOCLOSED_QUEUE = 'Auto-Closed';

    public static final String LEAD_SERVICE_PROCESSING_QUEUE = 'Lead Service Processing';

    private static final Map<String, Group> queuesByName = new Map<String, Group>();

    /**
     * @param name
     * @return the queue by the given name
     */
    public static Group getQueue(String name) {
        if (!queuesByName.containsKey(name)) {
            Group queue = [
                SELECT Id, Name
                FROM Group
                WHERE Type = 'Queue'
                AND Name = :name
            ];

            queuesByName.put(name, queue);
        }

        return queuesByName.get(name);
    }

    /**
     * @param expectedName
     *            The expected name of the queue
     * @param actualId
     *            The actual Queue ID to check against the name of the queue
     *
     * @return whether the Queue ID matches the expected name
     */
    public static Boolean isQueueEquals(String expectedName, Id actualId) {
        return getQueue(expectedName).Id == actualId;
    }

    public static Id getMarketoProfileID() {
        
        User mktoUser = [SELECT Id, ProfileId FROM User WHERE Alias = 'marketo' ];
        System.debug('mktoUser ID >> '+ mktoUser.ProfileId);
        return mktoUser.ProfileId;
    }
}