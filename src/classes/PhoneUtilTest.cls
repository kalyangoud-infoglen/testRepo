@isTest
private class PhoneUtilTest {

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }

    @isTest
    private static void checkRestrictedPhone() {

        // Given
        String num = '6173381923';

        // When
        Test.startTest();

        Boolean result = PhoneUtil.checkRestrictedPhone(num);

        // Then
        Test.stopTest();

        System.assertEquals(false, result, 'phone should not be restricted');
    }
}