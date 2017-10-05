@isTest
private class NetsuiteServiceTest {

    /**
     * Test a search that returns a customer and at least one matching contact
     * within that customer.
     */
    @isTest
    private static void leadSearchReturnsCustomerAndContact() {

        // Params for the test
        String email = 'foo';
        String dunsNumber = 'bar';

        // Specify the mock and run the test
        Test.setMock(HttpCalloutMock.class, new NetsuiteServiceMock());
        Test.startTest();

        NetsuiteService service = new NetsuiteService();
        LeadSearchResult result = service.leadSearch(email, dunsNumber);

        // Validate the results
        Test.stopTest();

        System.assertEquals(1, result.size);
        System.assertEquals(1, result.items.size());
        System.assert(String.isNotBlank(result.rawRequest));
        System.assert(String.isNotBlank(result.rawResponse));
    }

    /**
     * Test a search that returns opportunities for a customer
     */
    @isTest
    private static void opportunitySearchReturnsOpportunities() {

        // Do the when
        Test.setMock(HttpCalloutMock.class, new LeadSearchNetsuiteWorkflowMock());
        Test.startTest();

        NetsuiteService.OpportunitySearchResult result =
                NetsuiteService.getInstance().opportunitySearch('110281368');

        // Validate the then
        Test.stopTest();

        System.assert(result.isSuccess(), 'result should indicate success');
        System.assertEquals(5, result.size, 'result.size');
        System.assertEquals(5, result.items.size(), 'result.items.size()');
        System.assertEquals('UP124333', result.items[0].id, 'opportunity.id');
        System.assertEquals('USD', result.items[0].currencyIsoCode, 'opportunity.currencyIsoCode');
        System.assertEquals('Commit', result.items[0].forecastType, 'opportunity.forecastType');
        System.assertEquals(16315.20, result.items[0].total, 'opportunity.total');
        System.assertEquals(100, result.items[0].probability, 'opportunity.probability');
    }

    /**
     * Instantiate a new `Meta` object and verify that
     * properties are working as expected.
     */
    @isTest
    private static void newMeta() {

        // Run the test
        Test.startTest();

        Meta meta = new Meta();
        String href = meta.href;

        // Validate results
        Test.stopTest();

        System.assertEquals(null, meta.href);
    }

    /**
     * Instantiate a new `NetsuiteAccount` object and verify that
     * properties are working as expected.
     */
    @isTest
    private static void newNetsuiteAccount() {

        // Run the test
        Test.startTest();

        NetsuiteAccount account = new NetsuiteAccount();
        String id = account.id;
        String accountNumber = account.accountNumber;
        String companyName = account.companyName;
        String dunsNumber = account.dunsNumber;
        String industry = account.industry;
        DateTime createdDate = account.createdDate;
        DateTime lastUpdatedDate = account.lastUpdatedDate;
        String currencyIsoCode = account.currencyIsoCode;
        Meta meta = account.meta;
        NetsuiteAddress address = account.address;
        List<NetsuiteEmployee> salesTeamMembers = account.salesTeamMembers;
        List<NetsuiteContact> contacts = account.contacts;

        // Validate results
        Test.stopTest();

        System.assertEquals(null, account.id);
        System.assertEquals(null, account.accountNumber);
        System.assertEquals(null, account.companyName);
        System.assertEquals(null, account.dunsNumber);
        System.assertEquals(null, account.industry);
        System.assertEquals(null, account.createdDate);
        System.assertEquals(null, account.lastUpdatedDate);
        System.assertEquals(null, account.currencyIsoCode);
        System.assertEquals(null, account.meta);
        System.assertEquals(null, account.address);
        System.assertEquals(null, account.salesTeamMembers);
        System.assertEquals(null, account.contacts);
    }

    /**
     * Instantiate a new `NetsuiteAddress` object and verify that
     * properties are working as expected.
     */
    @isTest
    private static void newNetsuiteAddress() {

        // Run the test
        Test.startTest();

        NetsuiteAddress address = new NetsuiteAddress();
        String street = address.street;
        String city = address.city;
        String state = address.state;
        String postalCode = address.postalCode;
        String country = address.country;

        // Validate results
        Test.stopTest();

        System.assertEquals(null, street);
        System.assertEquals(null, city);
        System.assertEquals(null, state);
        System.assertEquals(null, postalCode);
        System.assertEquals(null, country);
    }

    /**
     * Instantiate a new `NetsuiteContact` object and verify that
     * properties are working as expected.
     */
    @isTest
    private static void newNetsuiteContact() {

        // Run the test
        Test.startTest();

        NetsuiteContact contact = new NetsuiteContact();
        String id = contact.id;
        String firstName = contact.firstName;
        String lastName = contact.lastName;
        String email = contact.email; 
        String phone = contact.phone;
        String salutation = contact.salutation;
        String jobLevel = contact.jobLevel;
        String title = contact.title;
        String mobilePhone = contact.mobilePhone;
        DateTime createdDate = contact.createdDate;
        DateTime lastUpdatedDate = contact.lastUpdatedDate;
        Meta meta = contact.meta;

        // Validate results
        Test.stopTest();

        System.assertEquals(null, contact.id);
        System.assertEquals(null, contact.firstName);
        System.assertEquals(null, contact.lastName);
        System.assertEquals(null, contact.email); 
        System.assertEquals(null, contact.phone);
        System.assertEquals(null, contact.salutation);
        System.assertEquals(null, contact.jobLevel);
        System.assertEquals(null, contact.title);
        System.assertEquals(null, contact.mobilePhone);
        System.assertEquals(null, contact.createdDate);
        System.assertEquals(null, contact.lastUpdatedDate);
        System.assertEquals(null, contact.meta);
    }

    /**
     * Instantiate a new `NetsuiteEmployee` object and verify that
     * properties are working as expected.
     */
    @isTest
    private static void newNetsuiteEmployee() {

        // Run the test
        Test.startTest();

        NetsuiteEmployee employee = new NetsuiteEmployee();
        String role = employee.role;
        String id = employee.id;
        String firstName = employee.firstName;
        String lastName = employee.lastName;
        Meta meta = employee.meta;

        // Validate results
        Test.stopTest();

        System.assertEquals(null, employee.role);
        System.assertEquals(null, employee.id);
        System.assertEquals(null, employee.firstName);
        System.assertEquals(null, employee.lastName);
        System.assertEquals(null, employee.meta);
    }

    @testSetup
    private static void setup() {
        TestUtil.setup();
    }
}