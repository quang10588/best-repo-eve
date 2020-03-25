/**
 * Created by NDU1 on 06/06/2019.
 */

public class UserHandler implements ITrigger{
        /**
         * bulkBefore
         *
         * This method is called prior to execution of a BEFORE trigger. Use this to cache
         * any data required into maps prior execution of the trigger.
         */
    Public List<User> userList = new List<User>();

    Public List<String> trigrammes = new List<String>();

        public void bulkBefore(){
            userList=[SELECT Id, IdUniqueUtilisateur__c FROM User];
            for(User us : userList) {
                trigrammes.add(us.IdUniqueUtilisateur__c);

            }
        }
        /**
         * bulkAfter
         *
         * This method is called prior to execution of an AFTER trigger. Use this to cache
         * any data required into maps prior execution of the trigger.
         */
        public void bulkAfter(){

        }

        /**
         * beforeInsert
         *
         * This method is called iteratively for each record to be inserted during a BEFORE
         * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
         */

        public void beforeInsert(SObject so){
            User us = (User) so;
            String trigram =generateRandomString(3);
            While (trigrammes.contains(trigram)){
                trigram =generateRandomString(3);

            }
            us.IdUniqueUtilisateur__c=trigram;


        }

        /**
         * beforeUpdate
         *
         * This method is called iteratively for each record to be updated during a BEFORE
         * trigger.
         */
        public void beforeUpdate(SObject oldSo, SObject so){

        }

        /**
         * beforeDelete
         *
         * This method is called iteratively for each record to be deleted during a BEFORE
         * trigger.
         */
        public void beforeDelete(SObject so){

        }

        public void beforeUndelete(SObject so){

        }

        /**
         * afterInsert
         *
         * This method is called iteratively for each record inserted during an AFTER
         * trigger. Always put field validation in the 'After' methods in case another trigger
         * has modified any values. The record is 'read only' by this point.
         */
        public void afterInsert(SObject so){


        }
        /**
         * afterUpdate
         *
         * This method is called iteratively for each record updated during an AFTER
         * trigger.
         */
        public void afterUpdate(SObject oldSo, SObject so){

        }

        /**
         * afterDelete
         *
         * This method is called iteratively for each record deleted during an AFTER
         * trigger.
         */
        public void afterDelete(SObject so){

        }

        public void afterUndelete(SObject so){

        }

        /**
         * andFinally
         *
         * This method is called once all records have been processed by the trigger. Use this
         * method to accomplish any final operations such as creation or updates of other records.
         */
        public void andFinally() {
        }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    }