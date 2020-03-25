/**
 * Created by NDU1 on 06/06/2019.
 */

trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerFactory.createAndExecuteHandler(UserHandler.class);

}