public class DeleteEventBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext batchContext){
       String Query = 'Select Id, Name From Event__c Where Live__c = true AND End_Date_Time__c < LAST_N_MONTHS:2';
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext batchContext,List<Event__c> scope){
        if(!scope.isEmpty()){
            List<Database.DeleteResult> deleteResult =Database.delete(scope);
            for(Database.DeleteResult dr : deleteResult){
                if(!dr.isSuccess()){
                    List<Database.Error> errors = dr.getErrors();
                    String errorInString = String.join(errors, ',');
                    TransactionLogHandler.doHandleExceptionWithError(errorInString, 'DeleteEventBatch');
                }
            }
        }
    }
    public void finish(Database.BatchableContext batchContext){
        
        Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
        
        mail.setSubject(' Batch Processing has been Completed');
        List<String> toAddress = new List<String>();
        toAddress.add('AsadKamali29@gmail.com');
        mail.setToAddresses( toAddress );
        mail.setSenderDisplayName('AsadKamali');
        
        mail.setHtmlBody('The DeleteEventBatch Batch Processing has been Completed ');
    }
}