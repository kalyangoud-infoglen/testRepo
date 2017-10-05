public class NetsuiteAccount {

    public String id {get; set;}
    public String accountNumber {get; set;}
    public String companyName {get; set;}
    public String customerStatus {get; set;}
    public String dunsNumber {get; set;}
    public String industry {get; set;}
    public DateTime createdDate {get; set;}
    public DateTime lastUpdatedDate {get; set;}
    public String currencyIsoCode {get; set;}
    public Meta meta {get; set;}
    public NetsuiteAddress address {get; set;}
    public List<NetsuiteEmployee> salesTeamMembers {get; set;}
    public List<NetsuiteContact> contacts {get; set;}
}