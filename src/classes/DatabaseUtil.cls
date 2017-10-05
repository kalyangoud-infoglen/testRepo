public with sharing class DatabaseUtil {

    /**
     * Emulates the naive `update` operation but defaults to allowing
     * duplicate records to be saved.
     *
     * @param records The list of records to update
     *
     * @throws System.Exception just like naive `update`
     */
    public static void updateAllowSave(List<SObject> records) {
        updateAllowSave(records, new Database.DMLOptions());
    }

    /**
     * Emulates the naive `update` operation but defaults to allowing
     * duplicate records to be saved.
     *
     * @param records The list of records to update
     * @param options The options to use when updating the records
     *
     * @throws System.Exception just like naive `update`
     */
    public static void updateAllowSave(
            List<SObject> records, Database.DMLOptions options) {

        // Always allow saving duplicate records
        options.duplicateRuleHeader.allowSave = true;
        options.optAllOrNone = true;  // cause errors to be thrown

        // Update records and throw exceptions
        Database.update(records, options);
    }
}