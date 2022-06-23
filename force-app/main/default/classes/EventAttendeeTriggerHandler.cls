public class EventAttendeeTriggerHandler {
    
    public static void sendConfirmationEmail(List<Event_Attendee__c> newRecordList) {
       
        Set<Id> attendeesIdsSet = new Set<Id>();
        Set<Id> eventIdsSet = new Set<Id>();
  
        for(Event_Attendee__c ea : newRecordList){
            attendeesIdsSet.add(ea.Attendee__c);
            eventIdsSet.add(ea.Event__c);
        }
        Map<Id ,Attendee__c> attendeeMap =new Map<Id,Attendee__c>(
            [Select Id, Name, Email__c From Attendee__c Where Id IN : attendeesIdsSet]
        );
        Map<Id , Event__c> eventMap =  new Map<Id ,Event__c>(
            [Select Id, Name__c,Start_DateTime__c,
             Event_Organizer__c, Event_Organizer__r.Name,
             Location__c, Location__r.Name, Location__r.City__c,
             Location__r.State__c, Location__r.Country__c,
             Location__r.Postal_Code__c,Location__r.Street__c
             From Event__c Where ID IN: eventIdsSet]
        );

         List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();         
        for(Event_Attendee__c ea : newrecordList){
            
            Attendee__c att = attendeeMap.get(ea.Attendee__c);
            Event__c evt =eventMap.get(ea.Event__c);
            
            
            Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();

            
            
            mail.setSubject('Pass for the '+evt.Name__c);
            List<String> toAddress = new List<String>();
            toAddress.add(att.Email__c);
            mail.setToAddresses( toAddress );
            mail.setSenderDisplayName(evt.Event_Organizer__r.Name);
 
            String  location  = 'https://www.google.com/maps/place/'+evt.Location__r.Street__c+' '
                +evt.Location__r.City__c+' '+evt.Location__r.State__c+' '+
                evt.Location__r.Country__c+' '+evt.Location__r.Postal_Code__c;
            
            String hrefForLocation ='<a href='+location+'"'+'target="_blank">Here</a>';
            String emailBody = 'Dear'+ att.Name+ ','+
                'Thank you for registration for '+ evt.Name__c+' Which will be organized on'+
                 evt.Start_DateTime__c+ ' &will held in '+ evt.Location__r.Name
                 +'.we are excited to have you,'+
                'see you in the event.<br/>'+
                
                 'Find the Google map Location for the Event'+hrefForLocation+'<br/>'+
                'Thanks,<br/>'+evt.Event_Organizer__r.Name;
            
            mail.setHtmlBody(emailBody);
            emailList.add(mail);
        }
        try{
            
           List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailList,true);
            for(Messaging.SendEmailResult email : results){
                System.debug(email.isSuccess());
                if(!email.isSuccess()){
                    List<Messaging.SendEmailError> errors = email.getErrors(); 
                    TransactionLogHandler.doHandleExceptionWithError(JSON.serialize(errors) , 'EventAttendeeTriggerHandler');
                }
            }
        }catch(System.Exception ex){
            TransactionLogHandler.doHandleException(ex, 'EventAttendeeTriggerHandler'); 
        }
    }
}