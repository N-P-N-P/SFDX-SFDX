public class DeploymentTaskHandler {
    public static void deploymenttask(list<Deployment_Task__c> deploymenttasks){
        for(Deployment_Task__c DT:deploymenttasks)
        {
            if(String.isBlank(DT.Task_Description__c)){
                DT.Task_Description__c = 'Manual Task';
            }
            if(String.isBlank(DT.Type__c)){
                DT.Type__c= 'Manual Task';
            }
            if (DT.Reviewed__c == false || DT.Reviewed__c== null) {
                DT.Reviewed__c= true;
            }
            
        }
        
    }
    
    
}