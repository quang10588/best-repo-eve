/**
 * Created by Aurélien Clerc on 31/07/2019.
 */

trigger TR02_OpportunitySplit on OpportunitySplit (before delete, before insert) {
    TriggerFactory.createAndExecuteHandler(HDL02_OpportunitySplit.class);
}