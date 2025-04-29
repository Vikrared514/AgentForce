global class AvailableSlots_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        AvailableSlots_Batch batch = new AvailableSlots_Batch();
        Database.executeBatch(batch, 200);
    }
}