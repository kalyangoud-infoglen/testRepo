public with sharing class OauthUtil {
    public static void sign(HttpRequest req, OauthCredential__c credential) {
        new OAuth().sign(req ,credential);
    }
}