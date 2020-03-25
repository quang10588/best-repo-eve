trigger EXPLORE_CustomMappingAccount on Account (before insert) {
    //Adaptation spéficique du connecteur Explore pour le contexte Bouygues
    for (Account acc : Trigger.new) {
        if (acc.explore_data__EXPLORE_OriginFromExplore__c) {
            acc.RaisonSociale__c = acc.Name;
            acc.ShippingStreet = acc.explore_data__EXPLORE_L4_VOIE__c;
            acc.ShippingCity = acc.explore_data__EXPLORE_COMMUNE__c;
            acc.ShippingPostalCode = acc.explore_data__EXPLORE_CP__c;
            acc.ShippingCountry = 'France';
            acc.siret__c = acc.explore_data__EXPLORE_Siret__c;
        }
    }
}