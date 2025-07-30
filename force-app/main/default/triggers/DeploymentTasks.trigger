trigger DeploymentTasks on Deployment_Task__c (before insert, before update) {
    
    DeploymentTaskHandler.deploymenttask(trigger.New);

}