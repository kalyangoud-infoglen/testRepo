public class OAuth {
    
    public OAuth() {
        
    }
    
    private Map<String,String> getParameters() {
		Map<String,String> parameters = new Map<String,String>();
		parameters.put('oauth_signature_method', 'HMAC-SHA1');
		parameters.put('oauth_timestamp', String.valueOf(DateTime.now().getTime() / 1000));
		parameters.put('oauth_nonce', String.valueOf(Crypto.getRandomLong()));
		parameters.put('oauth_version', '1.0');
		return parameters;
	}

	private Map<String,String> getUrlParams(String queryString) {

		Map<String,String> res = new Map<String,String>();
		if(queryString == null || queryString == '') {
			return res;
		}
		
		for(String s : queryString.split('&')) {
			//System.debug('getUrlParams: '+s);
			List<String> kv = s.split('=');
			if(kv.size() > 1) {
			  // RFC 5849 section 3.4.1.3.1 and 3.4.1.3.2 specify that parameter names 
			  // and values are decoded then encoded before being sorted and concatenated
			  // Section 3.6 specifies that space must be encoded as %20 and not +
			  String name = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[0], 'UTF-8'), 'UTF-8').replace('+','%20');
			  String value = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[1], 'UTF-8'), 'UTF-8').replace('+','%20');
			  res.put(name, value);
			}
		}
		return res;
	}

	private String createBaseString(Map<String,String> oauthParams, HttpRequest request) {
		Map<String,String> p = oauthParams.clone();
		if(request.getMethod().equalsIgnoreCase('post') && request.getBody() !=null && request.getHeader('Content-Type') == 'application/x-www-form-urlencoded') {
		   	p.putAll(getUrlParams(request.getBody()));
		}
		String host = request.getEndpoint();
		Integer n = host.indexOf('?');
		if(n>-1) {
			p.putAll(getUrlParams(host.substring(n+1)));
			host = host.substring(0,n);
		}
		List<String> keys = new List<String>();
		keys.addAll(p.keySet());
		keys.sort();
		String s = keys.get(0)+'='+p.get(keys.get(0));
		for(Integer i=1;i<keys.size();i++) {
			s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
		}

		return request.getMethod().toUpperCase()+ '&' + 
			EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
			EncodingUtil.urlEncode(s, 'UTF-8');
	}
	
	public void sign(HttpRequest request, OauthCredential__c credential) {

		Map<String,String> parameters = getParameters();
		
		parameters.put('oauth_consumer_key', credential.consumerKey__c);
		parameters.put('oauth_token', credential.token__c);
		
		String baseString = createBaseString(parameters, request);
		
		//System.debug('Signature base string: ' + baseString);
		
		Blob hmac = Crypto.generateMac('HmacSHA1', Blob.valueOf(baseString), Blob.valueOf(credential.consumerSecret__c + '&' + credential.tokenSecret__c));
				       	    
		String signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(hmac), 'UTF-8');
		//System.debug('Signature: '+signature);
		
		parameters.put('realm', credential.realm__c);
		
		String header = 'OAuth ';
		for (String key : parameters.keySet()) {
			header = header + key + '="' +parameters.get(key) + '", ';
		}
		header = header + 'oauth_signature="' + signature+'"';
		//System.debug('Authorization: '+header);
		request.setHeader('Authorization',header);
	}
}