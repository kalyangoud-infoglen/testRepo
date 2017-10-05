public class AmazonSNSService extends AbstractAmazonService {

    private Url snsEndpoint = null;
    private String snsRegion = null;
    private String snsAccessKey = null;
    private String snsSigningKey = null;
    private String snsTopicArn = null;
    private String snsMessage = null;

    public AmazonSNSService(String amazonSettingsName) {
        super();

        // look up config record by name
        AmazonSettings__c settings = AmazonSettings__c.getValues(amazonSettingsName);

        if (settings == null) {
            throw new SNSServiceException('Amazon Settings not found for Name: ' + amazonSettingsName);
        }

        snsEndpoint = new Url(settings.Endpoint__c);
        snsRegion = settings.Region__c;
        snsAccessKey = settings.AccessKey__c;
        snsSigningKey = settings.SecretAccessKey__c;
        snsTopicArn = settings.ARN__c;
    }

    protected override void init() {
        endpoint = snsEndpoint;
        resource = '/';
        region = snsRegion;
        service = 'sns';
        accessKey = snsAccessKey;
        method = HttpMethod.XPOST;
        payload = Blob.valueOf(
            'Action=Publish' +
            '&Version=2010-03-31' +
            '&TopicArn=' + snsTopicArn +
            '&Message=' + uriEncode(snsMessage)
        );
        createSigningKey(snsSigningKey);
   }

   public AmazonSNSResult publish(String message) {
        snsMessage = message;
        HttpResponse response;
        AmazonSNSResult result = new AmazonSNSResult();

        try {
            response = sendRequest();
            result.status = 'Success';
        }
        catch (ServiceException ex) {
            result.status = 'Error';
            result.errorMessage = ex.message;
        }
        catch (Exception ex) {
            result.status = 'Error';
            result.errorMessage = ex.getMessage();
        }
        finally {
            result.rawRequest = rawRequest;
            result.rawResponse = rawResponse;
        }

        return result;
   }

   public class SNSServiceException extends Exception {}

}