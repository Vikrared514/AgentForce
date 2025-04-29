global class CreateAvailableSlotsBatch implements Database.Batchable<SObject> {
    private static final Time SLOT_START = Time.newInstance(10, 0, 0, 0);
    private static final Time SLOT_END = Time.newInstance(18, 0, 0, 0);
    private static final Integer SLOT_DURATION_MINUTES = 15;
    private static final Integer SLOT_INCREMENT_MINUTES = 15;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id
            FROM User
            WHERE IsActive = TRUE AND Type__c = 'Doctor']);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Available_Slot__c> slotsToInsert = new List<Available_Slot__c>();
        
        
        Date thisWednesday = System.today();
        Datetime dt = (Datetime)thisWednesday;
        String dayOfWeek = dt.format('EEEE'); // EEEE will output the full day name
        System.debug('Today is: ' + dayOfWeek); //Monday
        
        
        // Loop through each doctor in the scope
        for (SObject s : scope) {
            User doctor = (User)s;
            
            // Loop 8 days from this Wednesday to next Wednesday
            for (Integer i = 0; i <=6; i++) {
                Date currentDate = thisWednesday.addDays(i);
                Time currentTime = SLOT_START;
                
                while (currentTime.addMinutes(SLOT_DURATION_MINUTES) <= SLOT_END) {
                    slotsToInsert.add(new Available_Slot__c(
                        Doctor__c = doctor.Id,
                        Date__c = currentDate,
                        Start_time__c = currentTime,
                        End_time__c = currentTime.addMinutes(SLOT_DURATION_MINUTES),
                        Status__c = 'Available'
                    ));
                    
                    // Move to next slot
                    currentTime = currentTime.addMinutes(SLOT_INCREMENT_MINUTES);
                }
                
                /* Datetime slotStart = Datetime.newInstance(currentDate, Time.newInstance(10, 0, 0, 0));
Datetime slotEnd = Datetime.newInstance(currentDate, Time.newInstance(18, 0, 0, 0));

while (slotStart < slotEnd) {
Datetime slotFinish = slotStart.addMinutes(15);

appointments.add(new Appointment__c(
Date__c = currentDate,
Start_Time__c =  (Time)slotStart.time();// slotStart.format('hh:mm a'),
End_Time__c =   slotFinish.format('hh:mm a'),
Doctor__c = doctor.Id // Assuming this is the lookup to User
));

slotStart = slotFinish;
}*/
            }
        }
        
        
        if (!slotsToInsert.isEmpty()) {
            try {
                System.debug('slotsToInsert: ' + slotsToInsert);
                
                // Use Database.insert with allOrNone = false
                Database.SaveResult[] results = Database.insert(slotsToInsert, false);
                
                // Loop through the results and debug success/failure
                for (Integer i = 0; i < results.size(); i++) {
                    if (results[i].isSuccess()) {
                        System.debug('Record inserted successfully: ' + slotsToInsert[i].Id);
                    } else {
                        System.debug('Failed to insert record: ' + slotsToInsert[i]);
                        for (Database.Error err : results[i].getErrors()) {
                            System.debug('Error: ' + err.getMessage());
                        }
                    }
                }
                
            } catch (Exception e) {
                System.debug('Unexpected exception during insert: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Optional finish logic
    }
}