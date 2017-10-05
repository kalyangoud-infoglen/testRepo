/*
Based on https://gist.github.com/brianmfear/92cf05807ac4becbd21f (modified)

// Example implementation as follows:
    public class AmazonS3Service extends AbstractAmazonService {
        public override void init() {
            endpoint = new Url('https://s3.amazonaws.com/');
            resource = '/';
            region = 'us-east-1';
            service = 's3';
            accessKey = 'my-key-here';
            method = HttpMethod.XGET;
            //  Remember to set "payload" here if you need to specify a body
            //  payload = Blob.valueOf('some-text-i-want-to-send');
            //  This method helps prevent leaking secret key,
            //  as it is never serialized
            createSigningKey('my-secret-key-here');
       }
       public String[] getBuckets() {
           HttpResponse response = sendRequest();
           String[] results = new String[0];
           // Read response XML; if we get this far, no exception happened
           // This code was omitted for brevity
           return results;
       }
    }
*/
public abstract class AbstractAmazonService {
    //  Post initialization logic (after constructor, before call)
    protected abstract void init();

    //  XML Node utility methods that will help read elements
    public static String getChildNodeText(Dom.XmlNode node, String ns, String name) {
        try {
            return node.getChildElement(name, ns).getText();
        } catch(Exception e) {
            return null;
        }
    }

    //  Turns an Amazon exception into something we can present to the user/catch
    public class ServiceException extends Exception {
        public String code;
        public String message;
        public String resource;
        public String requestId;

        public ServiceException(Dom.XmlNode node) {
            String ns = node.getNamespace();
            code = getChildNodeText(node.getChildElement('Error', ns), ns, 'Code');
            message = getChildNodeText(node.getChildElement('Error', ns), ns, 'Message');
            resource = getChildNodeText(node, ns, 'Resource');
            requestId = getChildNodeText(node, ns, 'RequestId');
        }

        public String toString() {
            return JSON.serialize(this);
        }
    }

    //  Things we need to know about the service. Set these values in init()
    protected String host;
    protected String region;
    protected String service;
    protected String resource;
    protected String accessKey;
    protected String payloadSha256;
    protected Url endpoint;
    protected HttpMethod method;
    protected Blob payload;
    protected String rawRequest;
    protected String rawResponse;

    //  Not used externally, so we hide these values
    private Blob signingKey;
    private DateTime requestTime;
    private Map<String, String> queryParams;
    private Map<String, String> headerParams;

    //  Make sure we can't misspell methods
    public enum HttpMethod { XGET, XPUT, XHEAD, XOPTIONS, XDELETE, XPOST }

    //  Add a header
    protected void setHeader(String key, String value) {
        headerParams.put(key.toLowerCase(), value);
    }

    //  Add a query param
    protected void setQueryParam(String key, String value) {
        queryParams.put(key.toLowerCase(), uriEncode(value));
    }

    //  Call this constructor with super() in subclasses
    protected AbstractAmazonService() {
        requestTime = DateTime.now();
        queryParams = new Map<String, String>();
        headerParams = new Map<String, String>();
        payload = Blob.valueOf('');
    }

    //  Create a canonical query string (used during signing)
    private String createCanonicalQueryString() {
        String[] results = new String[0];
        String[] keys = new List<String>(queryParams.keySet());
        keys.sort();
        for(String key : keys) {
            results.add(key + '=' + queryParams.get(key));
        }
        return String.join(results, '&');
    }

    //  Create the canonical headers (used for signing)
    private String createCanonicalHeaders(String[] keys) {
        String[] results = new String[0];
        keys.addAll(headerParams.keySet());
        keys.sort();
        for(String key : keys) {
            results.add(key + ':' + headerParams.get(key));
        }
        return String.join(results, '\n')+'\n';
    }

    //  Create the entire canonical request
    private String createCanonicalRequest(String[] headerKeys) {
        return String.join(
            new String[] {
                method.name().removeStart('X'),         //  METHOD
                new Url(endPoint, resource).getPath(),  //  RESOURCE
                createCanonicalQueryString(),           //  CANONICAL QUERY STRING
                createCanonicalHeaders(headerKeys),     //  CANONICAL HEADERS
                String.join(headerKeys, ';'),           //  SIGNED HEADERS
                payloadSha256                           //  SHA256 PAYLOAD
            },
            '\n'
        );
    }

    //  We have to replace ~ and " " correctly, or we'll break AWS on those two characters
    protected string uriEncode(String value) {
        return value == null ? null :
            EncodingUtil.urlEncode(value, 'utf-8').replaceAll('%7E','~').replaceAll('\\+','%20');
    }

    //  Create the entire string to sign
    private String createStringToSign(String[] signedHeaders) {
        String result = createCanonicalRequest(signedHeaders);
        return String.join(
            new String[] {
                'AWS4-HMAC-SHA256',
                headerParams.get('x-amz-date'),
                String.join(
                    new String[] {
                        requestTime.formatGMT('YYYYMMdd'),
                        region,
                        service,
                        'aws4_request'
                    },
                    '/'
                ),
                EncodingUtil.convertToHex(
                    Crypto.generateDigest('sha256', Blob.valueof(result))
                )
            },
            '\n'
        );
    }

    //  Create our signing key
    protected void createSigningKey(String secretKey) {
        signingKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'),
            Crypto.generateMac('hmacSHA256', Blob.valueOf(service),
                Crypto.generateMac('hmacSHA256', Blob.valueOf(region),
                    Crypto.generateMac('hmacSHA256',
                        Blob.valueOf(requestTime.formatGMT('YYYYMMdd')),
                        Blob.valueOf('AWS4'+secretKey)
                    )
                )
            )
        );
    }

    //  Create all of the bits and pieces using all utility functions above
    private HttpRequest createRequest() {
        HttpRequest request = new HttpRequest();
        String finalEndpoint = null;
        String queryString = null;
        String[] headerKeys = new String[0];
        String stringToSign = null;

        init();

        // set HTTP method
        request.setMethod(method.name().removeStart('X'));

        // date header value
        setHeader('x-amz-date', requestTime.formatGMT('YYYYMMdd\'T\'HHmmss\'Z\''));

        // host header value
        if(host == null) {
            host = endpoint.getHost();
        }
        setHeader('host', host);

        // payload related header values
        payloadSha256 = EncodingUtil.convertToHex(
            Crypto.generateDigest('sha-256', payload)
        );
        if(payload.size() > 0) {
            setHeader('x-amz-content-sha256', payloadSha256);
            setHeader('Content-Length', String.valueOf(payload.size()));
            request.setBodyAsBlob(payload);
        }

        // set endpoint url including querystring
        finalEndpoint = new Url(endpoint, resource).toExternalForm();
        queryString = createCanonicalQueryString();
        if(queryString != '') {
            finalEndpoint += '?'+queryString;
        }
        request.setEndpoint(finalEndpoint);

        // add header values to request
        for(String key: headerParams.keySet()) {
            request.setHeader(key, headerParams.get(key));
        }

        // set authorization headers
        stringToSign = createStringToSign(headerKeys);
        request.setHeader(
            'Authorization',
            String.format(
                'AWS4-HMAC-SHA256 Credential={0},SignedHeaders={1},Signature={2}',
                new String[] {
                    String.join(
                        new String[] {
                            accessKey,
                            requestTime.formatGMT('YYYYMMdd'),
                            region,
                            service,
                            'aws4_request'
                        },
                        '/'
                    ),
                    String.join(headerKeys, ';'),
                    EncodingUtil.convertToHex(
                        Crypto.generateMac(
                            'hmacSHA256',
                            Blob.valueOf(stringToSign),
                            signingKey)
                    )
                }
            )
        );

        return request;
    }

    //  Actually perform the request, and throw exception if response code is not valid
    protected HttpResponse sendRequest(Set<Integer> validCodes) {
        HttpRequest request = createRequest();
        rawRequest = request.getBody();
        System.debug(rawRequest);

        HttpResponse response = new Http().send(request);
        rawResponse = response.getBody();
        System.debug(rawResponse);

        if(!validCodes.contains(response.getStatusCode())) {
            throw new ServiceException(response.getBodyDocument().getRootElement());
        }
        return response;
    }

    //  Same as above, but assume that only 200 is valid
    //  This method exists because most of the time, 200 is what we expect
    protected HttpResponse sendRequest() {
        return sendRequest(new Set<Integer> { 200 });
    }
}