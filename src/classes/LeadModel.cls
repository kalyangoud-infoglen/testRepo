public class LeadModel {

    public String accessCode { get; set; }
    public Boolean canadaOptIn { get; set; }
    public String company { get; set; }
    public Boolean consultant { get; set; }
    public String countryCode { get; set; }
    public String email { get; set; }
    public String firstName { get; set; }
    public String typeOfUse { get; set; }
    public String jobLevel { get; set; }
    public String language { get; set; }
    public String lastName { get; set; }
    public String leadSource { get; set; }
    public Id ownerId { get; set; }
    public String phone { get; set; }
    public String remoteIp { get; set; }
    public String stateCode { get; set; }
    public String title { get; set; }
    public String sourceName {get;set;}
    public String platformLeadId {get;set;}

    public LeadModel() {
        this.firstName = null;
        this.accessCode = null;
        this.canadaOptIn = false;
        this.company = null;
        this.consultant = false;
        this.countryCode = null;
        this.email = null;
        this.typeOfUse = null;
        this.jobLevel = null;
        this.language = null;
        this.lastName = null;
        this.leadSource = null;
        this.ownerId = null;
        this.phone = null;
        this.remoteIp = null;
        this.stateCode = null;
        this.title = null;
        this.sourceName = null;
        this.platformLeadId = null;
    }
}