public with sharing class TaskUtil {

    /**
     * Type picklist value representing a phone call
     */
    public static final String CALL_TYPE = 'Call';

    /**
     * Status picklist value that indicates the task is completed and
     * does not require any further action.
     */
    public static final String COMPLETED_STATUS = 'Completed';

    /**
     * Type picklist value representing an email
     */
    public static final String EMAIL_TYPE = 'Email';

    /**
     * Static picklist value indicating action needs to be taken on the task.
     */
    public static final String OPEN_STATUS = 'Open';

    /**
     * @return a set of Type values that represent touchpoints
     */
    public static Set<String> getTouchpointTypeSet() {
        return new Set<String> { CALL_TYPE, EMAIL_TYPE };
    }
}