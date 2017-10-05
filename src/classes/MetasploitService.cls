public with sharing class MetasploitService {

    private String baseUrl;

    public MetasploitService() {

        // TODO: Remove hard-coded value
        this.baseUrl = 'https://updates.metasploit.com/services';
    }

    /**
     * @return an instance of the service for invoking web methods
     */
    public static MetasploitService getInstance() {
        return new MetasploitService();
    }

    public ValidateEmailResult validateEmail(String email) {
        ValidateEmailResult result = new ValidateEmailResult();

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(String.join(new List<String> {
            this.baseUrl + '/validate_email',
            HttpUtil.serializeQueryString(new Map<String, String> {
                'contactEmail' => email
            })
        }, '&'));

        HttpResponse res = new Http().send(req);

        return new ValidateEmailResult().readXmlString(res.getBody());
    }

    public class ValidateEmailResult {
        
        public String email {
            get;
            set {
                this.email = String.isBlank(value) ? null : value.trim();
            }
        }

        public String reason {
            get;
            set {
                this.reason = String.isBlank(value) ? null : value.trim();
            }
        }
        public Boolean valid { get; set; }

        public ValidateEmailResult readXmlString(String content) {
            Dom.Document doc = new Dom.Document();
            doc.load(content);

            Dom.XmlNode result = doc.getRootElement();
            this.email = result.getAttribute('email', null);
            this.reason = result.getAttribute('reason', null);
            this.valid = result.getAttribute('valid', null) == 'true';

            return this;
        }
    }
}