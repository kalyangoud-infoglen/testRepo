/*
 *    Linking Leads in Salesforce to NetSuite Customer and Contact records. 
 *    take the Lead is sa a parameter and perform a search of all Leads in 
 *    Salesforce that match that Id. 
 *    For each lead found in Salesforce use NetsuiteService to find correcponding
 *    corresponding Leads in NetSuite (using Lead email and DUNS num).
 *    Update the Lead with NetSute CustomerId and ContactId values
 *    Perform exception cheks.
 */

public class LeadSearchNetsuiteService {

    private List<Lead> systemLeads { get; set; }
    private NetsuiteService netsuite { get; set; }

    public LeadSearchNetsuiteService() {
        this.systemLeads = new List<Lead>();
        this.netsuite = new NetsuiteService();
    }

    /**
     * Given a list of leads, if the lead has either a D-U-N-S Number or
     * an Email value, search NetSuite to see if we can find an existing
     * customer and contact. If found, set the appropriate NetSuite fields
     * on the lead record.
     *
     * @param records The list of leads
     *
     * @return The list of leads, enriched with customer and contact IDs 
     *         found in NetSuite
     */
    public List<Lead> enrichLeads(List<Lead> records) {

        // NetSuite customer status values are all upper case, but SFDC is not 
        // in order to keep things cinsistent creating a map to bring NetSuite 
        // values to SFDC standards. 
        Map<String, String> customerStatusMap = new Map<String, String>{
            'CUSTOMER' => 'Customer', 
            'PROSPECT' => 'Prospect', 
            'LEAD' => 'Lead'
        };
        // Loop through each found Lead and do NetSuite Search 
        for(Lead eachLead : records) {

            // Call NetSuite
            LeadSearchResult result = netsuite.leadSearch(
                    eachLead.Email, eachLead.CompanyDunsNumber);

            // Capture raw request and response for troubleshooting
            String rawRequest = result.rawRequest;
            String rawResponse = result.rawResponse;

            if (rawRequest != null && rawRequest.length() > 255) {
                rawRequest = rawRequest.left(255);
            }
            if (rawResponse != null && rawResponse.length() > 32768) {
                rawResponse = rawResponse.left(32768);
            }

            eachLead.SearchNetsuiteRequest__c = rawRequest;
            eachLead.SearchNetsuiteResponse__c = rawResponse;

            NetsuiteAccount nsAccount = null;

            // Make sure that there were Leads fond in NetSuite
            if (result.size > 0) {

                // Get a map of contacts by email, since we'll need to
                // check this regardless of whether we find an account
                Map<String, List<NetsuiteContact>> contactMap =
                        result.getContactsByEmail();
                
                // If we found a contact, it's easy to store both the contact
                // and the account associated with that contact.
                // Otherwise we'll need to look for the account match
                // by D-U-N-S.
                if (contactMap.containsKey(eachLead.Email)
                        && contactMap.get(eachLead.Email) != null
                        && !contactMap.get(eachLead.Email).isEmpty()) {

                    Map<String, NetsuiteAccount> accountsByContactId =
                            result.getAccountsByContactId();

                    // Examine matching contacts and select the one
                    // with the earliest created date. Give preference to
                    // contacts associated with accounts with customerStatus
                    // equal to "CUSTOMER", then consider contacts under
                    // accounts with other customerStatus values.
                    NetsuiteContact nsContact = null;
                    NetsuiteContact oldestCustomerContact = null;
                    NetsuiteContact oldestContact = null;
                    
                    for (NetsuiteContact eachContact : contactMap.get(eachLead.Email)) {
                        if (accountsByContactId.get(eachContact.id).customerStatus == 'CUSTOMER') {
                            if (oldestCustomerContact == null 
                                    || eachContact.createdDate < oldestCustomerContact.createdDate) {
                                oldestCustomerContact = eachContact;
                            }
                        }

                        if (oldestContact == null
                                || eachContact.createdDate < oldestContact.createdDate) {
                            oldestContact = eachContact;
                        }
                    }

                    if(oldestCustomerContact != null) {
                        nsContact = oldestCustomerContact;
                    }
                    else {
                        nsContact = oldestContact;
                    }

                    // Remember the Contact ID
                    eachLead.NetsuiteContactId__c =
                            nsContact.id;

                    // Remember the Customer ID
                    nsAccount = accountsByContactId.get(
                            eachLead.NetsuiteContactId__c);

                    if (nsAccount != null) {

                        eachLead.NetsuiteCustomerId__c =
                                nsAccount.id;
                    }
                }
                else {
                    Map<String, NetsuiteAccount> accountMap =
                            result.getAccountsByDunsNumber();

                    if (accountMap.containsKey(eachLead.CompanyDunsNumber)) {

                        nsAccount = accountMap.get(eachLead.CompanyDunsNumber);

                        eachLead.NetsuiteCustomerId__c =
                                nsAccount.id;
                    }
                }

                // If an account was located, add a few more details
                // from that account to the lead record.
                if (nsAccount != null) {

                    // Set Customer Status
                    if (String.isNotBlank(nsAccount.customerStatus)
                            && customerStatusMap.containsKey(nsAccount.customerStatus)) {

                        eachLead.CustomerStatus__c = customerStatusMap.get(nsAccount.customerStatus);
                    } else {

                        eachLead.CustomerStatus__c = 'Lead';
                    }

                    // Set Netsuite BDR and TEM AE
                    if (nsAccount.salesTeamMembers != null) {

                        for (NetsuiteEmployee employee : nsAccount.salesTeamMembers) {

                            String fullName = null;
                            
                            if (String.isNotBlank(employee.firstName)) {
                                fullName = employee.firstName + ' ';
                            }

                            if (String.isNotBlank(employee.lastName)) {
                                fullName = fullName + employee.lastName;
                            }

                            if (String.isNotBlank(fullName)) {

                                if(fullName.length() > 255) {
                                    fullName = fullName.left(255);
                                }

                                if (employee.role == 'BusinessDevelopment') {
                                    // Set NetSuite BDR
                                    eachLead.Bdr__c = fullName;
                                } else if (employee.role == 'AccountExecutive') {
                                    // Set TEM AE
                                    eachLead.TemAe__c = fullName;
                                }
                            }
                        }
                    }
                }
            }
        }

        return records;
    }

    /**
     * Given a list of leads, which we assume to have NetSuite Customer ID
     * values, this method searches NetSuite for opportunities and dumps
     * the result into the NetSuite Opportunities text field. The updated
     * leads are then returned to the calling method for futher processing.
     *
     * @param records The list of leads
     *
     * @return the list of leads, enriched with opportunities found in NetSuite
     */
    public List<Lead> enrichOpportunities(List<Lead> records) {
        for (Lead eachLead : records) {
            if (!String.isEmpty(eachLead.NetsuiteCustomerId__c)) {
                NetsuiteService.OpportunitySearchResult result =
                        netsuite.opportunitySearch(eachLead.NetsuiteCustomerId__c);

                if (result.isSuccess()) {
                    eachLead.NetsuiteOpportunities__c = result.getDescription();
                }
            }
        }

        return records;
    }
}