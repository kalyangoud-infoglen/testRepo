/**
 * Static utility methods to support the use of `AbstractProfiledAsyncJob`
 * and related classes.
 */
public with sharing class AsyncJobUtil {

    public static final String NOT_STARTED_STATUS = 'Not Started';

    public static final String REQUESTED_STATUS = 'Requested';

    public static final String SKIPPED_STATUS = 'Skipped';

    public static final String ENQUEUED_STATUS = 'Enqueued';

    public static final String SUCCESS_STATUS = 'Success';

    public static final String ERROR_STATUS = 'Error';

    public static Set<String> getQualifiedPrereqStatusSet() {
        return new Set<String> {
            SKIPPED_STATUS,
            SUCCESS_STATUS
        };
    }

    public static Set<String> getQualifiedStatusSet() {
        return new Set<String> {
            NOT_STARTED_STATUS,
            REQUESTED_STATUS
        };
    }

    public static Boolean qualifyPrereqStatus(String status) {
        return getQualifiedPrereqStatusSet().contains(status);
    }

    /**
     * Determine whether a given job job status is considered qualified
     * and should move on for consideration to be enqueued or skipped
     * in the associated workflow.
     */
    public static Boolean qualifyStatus(String status) {
        return getQualifiedStatusSet().contains(status);
    }

    public static SObject stamp(SObject record, Schema.SObjectField field, String value) {
        SObject stamped = null;

        if (ENQUEUED_STATUS.equals(value)) {
            stamped = stampEnqueued(record, field);
        }
        else if (SKIPPED_STATUS.equals(value)) {
            stamped = stampSkipped(record, field);
        }

        return stamped;
    }

    public static SObject stampEnqueued(SObject record, Schema.SObjectField field) {
        record.put(field, AsyncJobUtil.ENQUEUED_STATUS);
        System.debug('JOB_ENQUEUED ' + field.getDescribe().label);
        return record;
    }

    /**
     * @return the given list of records with error values stamped into a field
     */
    public static List<SObject> stampError(List<SObject> records, Schema.SObjectField field) {
        for (SObject eachLead : records) {
            eachLead.put(field, AsyncJobUtil.ERROR_STATUS);
        }

        return records;
    }

    public static SObject stampSkipped(SObject record, Schema.SObjectField field) {
        record.put(field, AsyncJobUtil.SKIPPED_STATUS);
        System.debug('JOB_SKIPPED ' + field.getDescribe().label);
        return record;
    }

    /**
     * @return the given list of records with success values stamped into a field
     */
    public static List<SObject> stampSuccess(List<SObject> records, Schema.SObjectField field) {
        for (SObject eachLead : records) {
            eachLead.put(field, AsyncJobUtil.SUCCESS_STATUS);
        }

        return records;
    }
}