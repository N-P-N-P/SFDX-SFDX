trigger DeploymentTask on Deployment_Task__c (before insert,before update) {
    for(Deployment_Task__c DT:trigger.new)
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