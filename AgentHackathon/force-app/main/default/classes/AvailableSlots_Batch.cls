global class AvailableSlots_Batch implements Database.Batchable<SObject> {

    // Constants for slot times
    private static final Time SLOT_START = Time.newInstance(10, 0, 0, 0);
    private static final Time BREAK_START = Time.newInstance(12, 50, 0, 0);
    private static final Time BREAK_END = Time.newInstance(14, 0, 0, 0);
    private static final Time SLOT_END = Time.newInstance(18, 0, 0, 0);
    private static final Integer SLOT_DURATION_MINUTES = 30;
    private static final Integer SLOT_INCREMENT_MINUTES = 35;

    // Query to fetch active doctors
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id
            FROM User
            WHERE IsActive = TRUE AND Type__c = 'Doctor'
        ]);
    }

    // Creates time slots for each doctor
    global void execute(Database.BatchableContext BC, List<User> scope) {
        List<Available_Slot__c> slotsToInsert = new List<Available_Slot__c>();
        //Date slotDate = System.today(); 
        Date slotDate = System.today().addDays(1);
        for (User doctor : scope) {
            Time currentTime = SLOT_START;

            while (currentTime.addMinutes(SLOT_DURATION_MINUTES) <= SLOT_END) {

                if (currentTime >= BREAK_START && currentTime < BREAK_END) {
                    currentTime = BREAK_END;
                    continue;
                }

                // Create slot
                slotsToInsert.add(new Available_Slot__c(
                    Doctor__c = doctor.Id,
                    Date__c = slotDate,
                    Start_time__c = currentTime,
                    End_time__c = currentTime.addMinutes(SLOT_DURATION_MINUTES),
                    Status__c = 'Available'
                ));

                // Move to next slot
                currentTime = currentTime.addMinutes(SLOT_INCREMENT_MINUTES);
            }
        }

       /* if (!slotsToInsert.isEmpty()) {
            try {
                System.debug('slotsToInsert>.'+slotsToInsert);
                insert slotsToInsert;
            } catch (DmlException e) {
                System.debug('Error inserting slots: ' + e.getMessage());
            }
        }*/
        
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
        System.debug('Available slot batch processing completed.');
    }
}