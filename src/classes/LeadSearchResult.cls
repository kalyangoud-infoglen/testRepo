public class LeadSearchResult {

    public Integer size {get; set;}
    
    public List<NetsuiteAccount> items {get; set;}

    public String rawRequest {get; set;}

    public String rawResponse {get; set;}

    /**
     * @return A map of all found NetSuite accounts, keyed on each contact's
     *         Contact ID. If an account has no contacts, the account
     *         will not be mapped.
     */
    public Map<String, NetsuiteAccount> getAccountsByContactId() {
        Map<String, NetsuiteAccount> accountMap =
                new Map<String, NetsuiteAccount>();

        if (this.size > 0) {
            for (NetsuiteAccount eachAccount : this.items) {
                for (NetsuiteContact eachContact : eachAccount.contacts) {
                    accountMap.put(eachContact.id, eachAccount);
                }
            }
        }

        return accountMap;
    }

    /**
     * @return A map of all found NetSuite accounts, keyed on each account's
     *         D-U-N-S Number. If an account has no such number, the account
     *         will not be mapped.
     */
    public Map<String, NetsuiteAccount> getAccountsByDunsNumber() {
        Map<String, NetsuiteAccount> accountMap =
                new Map<String, NetsuiteAccount>();

        if (this.size > 0) {
            for (NetsuiteAccount eachAccount : this.items) {
                if (!String.isEmpty(eachAccount.dunsNumber)) {
                    accountMap.put(eachAccount.dunsNumber, eachAccount);
                }
            }
        }

        return accountMap;
    }

    /**
     * @return A map of all found contacts, keyed on email. If a contact
     *         doesn't have an email, the contact will not be mapped.
     */
    public Map<String, List<NetsuiteContact>> getContactsByEmail() {
        Map<String, List<NetsuiteContact>> contactMap =
                new Map<String, List<NetsuiteContact>>();

        if (this.size > 0) {
            for (NetsuiteAccount eachAccount : this.items) {
                for (NetsuiteContact eachContact : eachAccount.contacts) {
                    if (!String.isEmpty(eachContact.email)) {
                        String lowerCaseEmail = eachContact.email.toLowerCase();
                        if (!contactMap.containsKey(lowerCaseEmail)) {
                            contactMap.put(lowerCaseEmail, new List<NetsuiteContact>());
                        }
                        contactMap.get(lowerCaseEmail).add(eachContact);
                    }
                }
            }
        }

        return contactMap;
    }
}