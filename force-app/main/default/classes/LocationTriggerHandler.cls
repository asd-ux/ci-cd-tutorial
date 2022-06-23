public class LocationTriggerHandler {

    @future(callout=true)
    public static void verifyAddress(String recordId){
        Location__c loc =
            [Select Id, Name, Street__c , City__c , Postal_Code__c, State__c From  Location__c Where Id =:recordId];
                
            String baseURL =
           'https://us-street.api.smartystreets.com/street-address?auth-id=4bd4ca26-2b69-fc39-56e4-1a83b4f22f7e&auth-token=Rb3FWJesOhDHXD8qQgxg';
        
             baseURL +='&street='+EncodingUtil.urlEncode(loc.Street__c, 'UTF-8')
            +'&city='+EncodingUtil.urlEncode(loc.City__c, 'UTF-8')
            +'&state='+EncodingUtil.urlEncode(loc.State__c, 'UTF-8')
            +'&zipcode='+EncodingUtil.urlEncode(loc.Postal_Code__c, 'UTF-8')
            +'&match=invalid&candidates=10';
             
        
                 HttpRequest httpReq = new HttpRequest();
                 httpReq.setMethod('GET');
                 httpReq.setEndpoint(baseURL);
                 httpReq.setHeader('Content-Type',' application/json');
                 
        Http http = new Http();
        
        HttpResponse httpRes = new HttpResponse();
        
        try{
            httpRes = http.send(httpReq);
            System.debug('ResponseBody '+httpRes.getBody());
            if(httpRes.getStatusCode() == 200 && httpRes.getStatus() =='OK'){
                String responseBody = httpRes.getBody(); 
                if(String.isBlank(responseBody) && responseBody.length() > 2){
                    loc.Verified__c = true;
                }else{
                    loc.Verified__c = true;   
                }
                update loc;
            }
            else{
                TransactionLogHandler.doHandleExceptionWithError(httpRes.getBody() , 'LocationTriggerHandler');
            }
        }
        catch(System.CalloutException ex){
            System.debug('Exception Executed '+ex.getStackTraceString());
            TransactionLogHandler.doHandleException(ex, 'LocationTriggerHandler');
        }     
        } 
}