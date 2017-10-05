public interface LeadService {
    
    Lead createLead(String firstName, String lastName, String email, String phone, String company, String countryCode, String stateCode, String leadSource, String accessCode, String remoteIp, String language, Boolean consultant, Boolean canadaOptIn, String jobLevel, String title, String typeOfUse, String sourceName, String platformLeadId, Id id);

    Lead createLead(LeadModel model);
    
    void createCampaignMember(Id id, String campaignId);
    
    void createLeadKeyRecord(Id id, String platformLeadId);
}