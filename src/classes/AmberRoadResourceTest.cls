@isTest
private class AmberRoadResourceTest {

    @testSetup
	private static void setup() {
        TestUtil.setup();
	}
	
	/**
	 * Use 'doPost' to create a Amber Road Request
	 **/
	 @isTest
	 private static void doPost(){
	     
	     Test.startTest();
	     
	     String companyName = 'Rapid7';
	     String contactName = 'TEST';
	     String secondaryContactName = 'Amber Road';
	     String streetAddress1 = '200 Central Ave';
	     String streetAddress2 = '';
	     String streetAddress3 = '';
	     String city = 'Boston';
	     String stateCode ='MA';
	     String countryCode = 'US';
	     String postalCode = '02556';
	     String email = 'test@example.com';
	     String ip = '192.168.0.1';
	     
	     //Stage the REST reponse
	      RestContext.response = new RestResponse();
	      
	      AmberRoadResource.doPost(
	          companyName,
	          contactName,
	          secondaryContactName,
	          streetAddress1,
	          streetAddress2,
	          streetAddress3,
	          city,
	          stateCode,
	          countryCode,
	          postalCode,
	          email,
	          ip);
	          
	     //Validate the then 
	     Test.stopTest();
	     
	     AmberRoadRequest__c amber = [
	         Select Id, Company__c
	         FROM AmberRoadRequest__c
	         WHERE Company__c = 'Rapid7'
	         ];
	         
	      System.assertEquals('Rapid7', amber.Company__c);
	     
	 }
}