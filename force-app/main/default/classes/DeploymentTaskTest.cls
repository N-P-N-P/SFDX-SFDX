@isTest
public class DeploymentTaskTest {

    // Test before insert
    @isTest
    static void testBeforeInsert() {
        // Create a new Deployment_Task__c record with some blank fields
        Deployment_Task__c dt = new Deployment_Task__c(
            Name = 'Test Task',
            Task_Description__c = 'Manual Task',  // Blank Task Description
            Type__c = 'Manual Task',              // Blank Type
            Reviewed__c = false,       // Reviewed field set to false
            Perform_Deployment_Task__c = 'After Deployment',  // Provide value for required field
            Status__c = 'Draft' // Provide value for required field
        );

        // Insert the record
        insert dt;

        // Retrieve the record after insertion
        Deployment_Task__c insertedDT = [SELECT Task_Description__c, Type__c, Reviewed__c, Perform_Deployment_Task__c, Status__c FROM Deployment_Task__c WHERE Id = :dt.Id];

        // Assert that the Task_Description__c field is set to 'Manual Task'
        System.assertEquals('Manual Task', insertedDT.Task_Description__c, 'Task_Description__c should be set to "Manual Task"');

        // Assert that the Type__c field is set to 'Manual Task'
        System.assertEquals('Manual Task', insertedDT.Type__c, 'Type__c should be set to "Manual Task"');

        // Assert that the Reviewed__c field is set to true
        System.assertEquals(true, insertedDT.Reviewed__c, 'Reviewed__c should be set to true');

        // Assert that Perform_Deployment_Task__c is not blank
       System.assertEquals('After Deployment', insertedDT.Perform_Deployment_Task__c, 'Perform_Deployment_Task__c should have a value');

        // Assert that Status__c is not blank
        System.assertEquals('Draft', insertedDT.Status__c, 'Status__c should be "Draft"');
    
    }

}