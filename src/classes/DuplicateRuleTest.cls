/**
 * Tests which validate expected behavior for interactions between Apex DML
 * operations and duplicate rules.
 *
 * @see PHX-1603
 */
@isTest
private class DuplicateRuleTest {

    @testSetup
    private static void setup() {
        Lead daffy = new Lead(
                FirstName = 'Daffy',
                LastName = 'Duck (TEST)',
                Company = 'Acme Corporation (TEST)');

        Lead marvin = new Lead(
                FirstName = 'Marvin',
                LastName = 'the Martian (TEST)',
                Company = 'Acme Corporation (TEST)');

        Lead marvin2 = new Lead(
                FirstName = 'Marvin',
                LastName = 'the Martian (TEST)',
                Company = 'Acme Corporation (TEST)');

        insert new List<Lead> { daffy, marvin, marvin2 };
    }

    /**
     * When a duplicate lead is attempted to be created in Apex,
     * an exception should be thrown with the DUPLICATES_DETECTED error code
     * as a result of an active duplicate rule handling the matching rule
     * which detected the duplicate.
     */
    @isTest
    private static void createFirstDuplicate() {

        // Given
        Lead bugs = new Lead(
                FirstName = 'Bugs',
                LastName = 'Bunny (TEST)',
                Company = 'Acme Corporation (TEST)');

        insert bugs;

        // When
        Test.startTest();

        System.DmlException caught = null;

        try {
            Lead duplicateBugs = new Lead(
                    FirstName = 'Bugs',
                    LastName = 'Bunny (TEST)',
                    Company = 'Acme Corporation (TEST)');

            insert duplicateBugs;
        }
        catch (System.DmlException thrown) {
            caught = thrown;
        }

        // Then
        Test.stopTest();

        System.assert(caught.getMessage().contains('DUPLICATES_DETECTED'),
                'DUPLICATES_DETECTED error code expected');
    }

    /**
     * Given that two duplicate leads exist, where the second one was created
     * with the header which allows saving duplicate leads, when another
     * duplicate lead is attempted to be created in Apex,
     * an exception should be thrown with the DUPLICATES_DETECTED error code
     * as a result of an active duplicate rule handling the matching rule
     * which detected the duplicate.
     */
    @isTest
    private static void createSecondDuplicate() {

        // Given
        Lead daffy = new Lead(
                FirstName = 'Daffy',
                LastName = 'Duck (TEST)',
                Company = 'Acme Corporation (TEST)');

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;

        // TODO: Figure out why the code below throws a System.DmlExcpetion
        //       with the DUPLICATES_DETECTED error code, even though
        //       the options should have been set correcetly
        // daffy.setOptions(options);
        // insert daffy;

        Database.SaveResult daffyInsert = Database.insert(daffy, options);
        System.assert(daffyInsert.isSuccess());

        System.assertEquals(2, [
            SELECT Id FROM Lead WHERE LastName = 'Duck (TEST)'
        ].size(), 'COUNT(Daffy leads)');

        // When
        Test.startTest();

        System.DmlException caught = null;

        try {
            Lead duplicateDaffy = new Lead(
                    FirstName = 'Daffy',
                    LastName = 'Duck (TEST)',
                    Company = 'Acme Corporation (TEST)');

            insert duplicateDaffy;
        }
        catch (System.DmlException thrown) {
            caught = thrown;
        }

        // Then
        Test.stopTest();

        System.assert(caught.getMessage().contains('DUPLICATES_DETECTED'),
                'DUPLICATES_DETECTED error code expected');
    }

    /**
     * Given that two duplicate leads exist, where the second one was created
     * with the header which allows saving duplicate leads, when one of the
     * duplicate leads is edited without changing the matching rule values,
     * an exception should be thrown with the DUPLICATES_DETECTED error code
     * as a result of an active duplicate rule handling the matching rule
     * which detected the duplicate.
     */
    @isTest
    private static void editFirstDuplicate() {

        // Given
        Lead daffy = new Lead(
                FirstName = 'Daffy',
                LastName = 'Duck (TEST)',
                Company = 'Acme Corporation (TEST)');

        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;

        // TODO: Figure out why the code below throws a System.DmlExcpetion
        //       with the DUPLICATES_DETECTED error code, even though
        //       the options should have been set correcetly
        // daffy.setOptions(options);
        // insert daffy;

        Database.SaveResult daffyInsert = Database.insert(daffy, options);
        System.assert(daffyInsert.isSuccess());

        System.assertEquals(2, [
            SELECT Id FROM Lead WHERE LastName = 'Duck (TEST)'
        ].size(), 'COUNT(Daffy leads)');

        // When
        Test.startTest();

        System.DmlException caught = null;

        try {
            Lead duplicateDaffy = new Lead(
                    Id = daffyInsert.getId(),
                    FirstName = 'daffy');

            update duplicateDaffy;
        }
        catch (System.DmlException thrown) {
            caught = thrown;
        }

        // Then
        Test.stopTest();

        System.assert(caught.getMessage().contains('DUPLICATES_DETECTED'),
                'DUPLICATES_DETECTED error code expected');
    }

    /**
     * Given that two duplicate leads exist, where the second one was created
     * with the header which allows saving duplicate leads, when one of the
     * duplicate leads is edited without changing the matching rule values,
     * an exception should be thrown with the DUPLICATES_DETECTED error code
     * as a result of an active duplicate rule handling the matching rule
     * which detected the duplicate.
     */
    @isTest
    private static void editExistingDuplicate() {

        // Given
        List<Lead> marvins = [
            SELECT Id
            FROM Lead
            WHERE FirstName = 'Marvin'
                AND LastName = 'the Martian (TEST)'
                AND Company = 'Acme Corporation (TEST)'
        ];

        System.assertEquals(2, marvins.size(), 'COUNT(Marvin leads)');

        // When
        Test.startTest();

        System.DmlException caught = null;

        try {
            update new Lead(Id = marvins[0].Id, FirstName = 'marvin');
        }
        catch (System.DmlException thrown) {
            caught = thrown;
        }

        // Then
        Test.stopTest();

        System.assert(caught.getMessage().contains('DUPLICATES_DETECTED'),
                'DUPLICATES_DETECTED error code expected');
    }
}