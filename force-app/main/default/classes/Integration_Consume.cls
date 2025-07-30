public class Integration_Consume {
    
    public static void Callout(){
        Http http =new Http();
        HttpRequest req = new httpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:Salesforce_Named_Credential/services/apexrest/DataAvailable');
        HttpResponse res= http.send(req);
        System.debug('Status code is'+res.getStatusCode());
        if(res.getStatusCode() == 302){
            System.debug('This is Data'+res.getBody());
        }
        
    }
    
}