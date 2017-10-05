@isTest
private class MetasploitServiceTest {

    /**
     * Given email address 'bugs@no.mail.domain';
     * When validateEmail method invoked;
     * Then result returned indicating failed validation
     */
    @isTest
    private static void validateEmailBugsAtNoMailDomain() {

        // Given
        String email = 'bugs@no.mail.server';

        // When
        Test.setMock(HttpCalloutMock.class, new MetasploitServiceMock());
        Test.startTest();

        MetasploitService.ValidateEmailResult result =
                MetasploitService.getInstance().validateEmail(email);

        // Then
        Test.stopTest();

        System.assertEquals(false, result.valid, 'result.valid');
        System.assertEquals('bugs@no.mail.server', result.email, 'result.email');
        System.assertEquals('No mail server', result.reason, 'result.reason');
    }

    /**
     * Given email address 'bugs@slalom.com';
     * When validateEmail method invoked;
     * Then result returned indicating passed validation
     */
    @isTest
    private static void validateEmailBugsAtSlalomCom() {

        // Given
        String email = 'bugs@slalom.com';

        // When
        Test.setMock(HttpCalloutMock.class, new MetasploitServiceMock());
        Test.startTest();

        MetasploitService.ValidateEmailResult result =
                MetasploitService.getInstance().validateEmail(email);

        // Then
        Test.stopTest();

        System.assertEquals(true, result.valid, 'result.valid');
        System.assertEquals('bugs@slalom.com', result.email, 'result.email');
        System.assertEquals(null, result.reason, 'result.reason');
    }

    /**
     * Given email address 'bugs@gmail.com';
     * When validateEmail method invoked;
     * Then result returned indicating passed validation
     */
    @isTest
    private static void validateEmailBugsAtGmailCom() {

        // Given
        String email = 'bugs@gmail.com';

        // When
        Test.setMock(HttpCalloutMock.class, new MetasploitServiceMock());
        Test.startTest();

        MetasploitService.ValidateEmailResult result =
                MetasploitService.getInstance().validateEmail(email);

        // Then
        Test.stopTest();

        System.assertEquals(true, result.valid, 'result.valid');
        System.assertEquals('bugs@gmail.com', result.email, 'result.email');
        System.assertEquals(null, result.reason, 'result.reason');
    }

    /**
     * Given email address 'bugs' which isn't a valid email address;
     * When validateEmail method invoked;
     * Then result returned indicating failed validation
     */
    @isTest
    private static void validateEmailBugs() {

        // Given
        String email = 'bugs';

        // When
        Test.setMock(HttpCalloutMock.class, new MetasploitServiceMock());
        Test.startTest();

        MetasploitService.ValidateEmailResult result =
                MetasploitService.getInstance().validateEmail(email);

        // Then
        Test.stopTest();

        System.assertEquals(false, result.valid, 'result.valid');
        System.assertEquals('bugs', result.email, 'result.email');
        System.assertEquals('Invalid email address', result.reason, 'result.reason');
    }
}