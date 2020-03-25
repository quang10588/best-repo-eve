public class PDFGeneratorController {
    // Lazy opportunity
    private final Opportunity p;
    public Opportunity opportunity {get;set;}
    private OpportunitySplit opportunitySplit;
    private final String logoResourceName = 'CompanyLogos';
    
    public List<BuildTypeList__c> ouvrages {get; set;}
    public List<Date> dateRemiseOffres {get;set;}
    public List<Stakeholder__c> listDeAMO {get;set;}
    public List<Stakeholder__c> listArchitectes {get;set;}
    public List<Stakeholder__c> listLesBet {get;set;}
    public String opportunityAmount {get;set;}
    public String opportunitySplitAmount {get;set;}
    public String coutPrevisionnelDesEtudes {get;set;}
    public String logo {get;set;}
    public String secondLogo {get;set;}
    public String opLink {get;set;}
    public String baseLink {get;set;}
    public User user {get;set;}
    public String currencyIsoCode {get;set;}
    public List<String> engineeringDirectionsList {get;set;}
    public String googleApiKey {get;set;}
    public String mapImageId {get;set;}
    public String resourcePath {
        get {
            String resourcePath = '';
            List<StaticResource> staticResource = [SELECT Id, Name, SystemModStamp FROM StaticResource where Name = :logoResourceName limit 1];
            if(staticResource != null && staticResource.size() > 0){
                if(staticResource[0].SystemModStamp != null) {
                    resourcePath = '/resource/' + (staticResource[0].SystemModStamp.getTime());
                }
            }
            return resourcePath;
        }
        set;
    }
     
    public String projectAddress {get;set;}
    private List<Stakeholder__c> stakeholders;

    public PDFGeneratorController(ApexPages.StandardController controller) {  
        this.opportunity = (Opportunity) controller.getRecord();
        
        this.ouvrages = findOuvragessByOpportunity(this.opportunity.Id);
        
        this.stakeholders = getListStakeholder(this.opportunity.Id);
        this.listArchitectes = getListArchirecteAccount(this.stakeholders);
        this.listLesBet = getListLesBetAccount(this.stakeholders);
        this.listDeAMO = getListDeAMOAccount(this.stakeholders);
        
        this.baseLink = URL.getSalesforceBaseUrl().toExternalForm();
        this.opLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+this.opportunity.Id;
        
        this.dateRemiseOffres = getOffresDate(this.opportunity.Id);

        this.engineeringDirectionsList = new List<String>();
        this.engineeringDirectionsList.add(System.Label.pdf_generator_engineering_direction_structure); //Structure
        this.engineeringDirectionsList.add(System.Label.pdf_generator_engineering_direction_bois); //Bois
        this.engineeringDirectionsList.add(System.Label.pdf_generator_engineering_direction_methodes); //Méthodes
        this.engineeringDirectionsList.add(System.Label.pdf_generator_engineering_direction_synthese); //Synthèse
        this.engineeringDirectionsList.add(System.Label.pdf_generator_engineering_direction_planning); //Planification
        this.engineeringDirectionsList.add(System.Label.pdf_generator_engineering_direction_energy); //Energies
        this.engineeringDirectionsList.add(System.Label.pdf_generator_engineering_direction_metal); //Métal

        this.opportunity = getOppExtraFields(this.opportunity);

        if(this.opportunity != null) {

            // Lookup symbol for the currency
            if(opportunity.CurrencyIsoCode == 'EUR') {
                this.currencyIsoCode = '€';
            } else if(opportunity.CurrencyIsoCode == 'GBP') {
                this.currencyIsoCode = '£';
            }
			
            // Get Opportunity amount
            if(this.opportunity.Amount != null) {
                this.opportunityAmount = convertCurrencyFormat(this.opportunity.Amount, 'M');
            }
            // Get Opportunity Split amounts
            this.opportunitySplit = [SELECT Id, convertCurrency(SplitAmount), convertCurrency(SplitRealOrderAmount__c), MontantSplitTC__c FROM  OpportunitySplit WHERE OpportunityId = :this.opportunity.Id limit 1];
            System.debug(this.opportunitySplit);
            if(this.opportunitySplit != null) {
                this.opportunitySplitAmount = convertCurrencyFormat(this.opportunitySplit.SplitAmount, 'M');
            }

            if(this.opportunity.CoutPrevisionnelDesEtudes__c != null) {
                this.coutPrevisionnelDesEtudes = convertCurrencyFormat(this.opportunity.CoutPrevisionnelDesEtudes__c, 'K', '€');
            }

            this.user = [SELECT Id, Name, toLabel(entite__c), toLabel(UO__c) FROM  USER  WHERE Id = :this.opportunity.OwnerId limit 1];
            this.logo = getLogo(user.entite__c, this.resourcePath + '/' + this.logoResourceName);
            this.secondLogo = getLogo(user.UO__c, this.resourcePath + '/' + this.logoResourceName);
        }

        this.googleApiKey = [SELECT id, DV_Flow_AP__key__c FROM DV_Flow_AP__PlacesAPI__c LIMIT 1].DV_Flow_AP__key__c;

        this.projectAddress = buildProjectAddress(this.opportunity);

        String pdfFileName = Datetime.now().format('yyyyMMdd');
        if(opportunity.city__c != null) {
            pdfFileName += ' ' + opportunity.city__c;
        }
        if(opportunity.street__c != null) {
            pdfFileName += ' ' + opportunity.street__c;
        }
        
        
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename="' +String.format(System.Label.pdf_generator_file_name, new List<String> {pdfFileName})+ '.pdf"');
    }

    public void initAction() {
        // The DML tasks
        this.mapImageId = this.getMap(this.projectAddress, this.opportunity.Id);
    }
    
    @TestVisible private static Opportunity getOppExtraFields(Opportunity opportunity) {
        Opportunity advOpp = [SELECT Id, convertCurrency(Amount), OwnerId, Street__c, City__c, ZIPCode__c, convertCurrency(CoutPrevisionnelDesEtudes__c), toLabel(editionType__c), toLabel(UO_entreprise__c), toLabel(Mode_de_financement__c), toLabel(Country__c), RecordType.Name, CurrencyIsoCode, toLabel(TypeOuvrage__c), toLabel(Consultation__c), toLabel(ContractTypeOpportunity__c) FROM  Opportunity WHERE Id = :opportunity.Id limit 1];
        opportunity.Amount = advOpp.Amount;
        opportunity.CurrencyIsoCode = advOpp.CurrencyIsoCode;
        opportunity.OwnerId = advOpp.OwnerId;
        opportunity.Street__c = advOpp.Street__c;
        opportunity.City__c = advOpp.City__c;
        opportunity.ZIPCode__c = advOpp.ZIPCode__c;
        opportunity.CoutPrevisionnelDesEtudes__c = advOpp.CoutPrevisionnelDesEtudes__c;
        opportunity.editionType__c = advOpp.editionType__c;
        opportunity.UO_entreprise__c = advOpp.UO_entreprise__c;
        opportunity.Mode_de_financement__c = advOpp.Mode_de_financement__c;
        opportunity.Country__c = advOpp.Country__c;
        opportunity.TypeOuvrage__c = advOpp.TypeOuvrage__c;
        opportunity.Consultation__c = advOpp.Consultation__c;
        opportunity.ContractTypeOpportunity__c = advOpp.ContractTypeOpportunity__c;
        return opportunity;
    }

    @TestVisible private String getLogo(String type, String resourcePath) {
        String logoPath = null;
        if(type != null && type != '') {
            type = type.replace(' ', '-');
            logoPath =  resourcePath + '/' + type + '.png';
            try {
                new PageReference(logoPath).getContent();
            } catch(VisualforceException e) {
                logoPath = 'NOT_FOUND';
                System.debug(e.getMessage());
            }
        }
        return logoPath;
    }

    @TestVisible private static List<BuildTypeList__c> findOuvragessByOpportunity(final String id) {
        return [SELECT toLabel(TypeOuvrage__c), quantity__c, typeOfQuantity__c, floorAreaSquareMeters__c, Master__c, Opportunity__c FROM BuildTypeList__c WHERE Opportunity__c = :id  ORDER BY CreatedDate LIMIT 4];
    }

    @TestVisible private static List<Date> getOffresDate(final String id) {
        List<Date> result = new List<Date>();
        List<Offre__c> offres = [SELECT DeliveredOfferDate__c, Opportunity__c FROM Offre__c WHERE Opportunity__c = :id ORDER BY CreatedDate LIMIT 3];
        for(Offre__c offre : offres) {
            result.add(offre.DeliveredOfferDate__c);
        }
        return result;
    }

    @TestVisible private static List<Stakeholder__c> getListDeAMOAccount(List<Stakeholder__c> stakeholders) {
        List<Stakeholder__c> accounts = new List<Stakeholder__c>();
        if(stakeholders.size() > 0){
            for(Stakeholder__c s : stakeholders) {
                if(s.AccountMission__c != null && s.AccountMission__c.isNumeric()) {
                    Integer missionId = s.AccountMission__c != null ? integer.valueof(s.AccountMission__c) : 0;
                    if(missionId >= 1 && missionId <= 10) {
                        accounts.add(s);
                    }
                }
            }
        }
        return accounts;
    }

    @TestVisible private static List<Stakeholder__c> getListArchirecteAccount(List<Stakeholder__c> stakeholders) {
        List<Stakeholder__c> accounts = new List<Stakeholder__c>();
        if(stakeholders.size() > 0){
            for(Stakeholder__c s : stakeholders) {
                if(s.AccountMission__c != null && s.AccountMission__c.isNumeric()) {
                    Integer missionId = s.AccountMission__c != null ? integer.valueof(s.AccountMission__c) : 0;
                    if(missionId >= 20 && missionId <= 30) {
                        accounts.add(s);
                    }
                }
            }
        }
        return accounts;
    }

    @TestVisible private static List<Stakeholder__c> getListLesBetAccount(List<Stakeholder__c> stakeholders) {
        List<Stakeholder__c> accounts = new List<Stakeholder__c>();
        if(stakeholders.size() > 0){
            Integer i = 0;
            for(Stakeholder__c s : stakeholders) {
                if(s.AccountMission__c != null && s.AccountMission__c.isNumeric()) {
                    Integer missionId = s.AccountMission__c != null ? integer.valueof(s.AccountMission__c) : 0;
                    if(missionId >= 100 && missionId <= 200) {
                        s.AccountMission__c = (String)s.get('AccountMissionName');
                        accounts.add(s);
                        i++;
                        if(i == 10) {
                            break;
                        }
                    }
                }
            }
        }
        return accounts;
    }

    @TestVisible private static List<Stakeholder__c> getListStakeholder(final String opportunityId) {
        return [SELECT Id, AccountName__c, toLabel(AccountMission__c) AccountMissionName, AccountMission__c, Opportunity__c FROM Stakeholder__c WHERE Opportunity__c = :opportunityId];
    }

    @TestVisible private static String buildProjectAddress(Opportunity opportunity) {
        //Format: Street__c + ZipCode__c + city__c + country__c
        String address = '';
        if(opportunity.Street__c != null && opportunity.Street__c != '') {
            address += opportunity.Street__c.trim();
        }
        if(opportunity.ZIPCode__c != null && opportunity.ZIPCode__c.trim() != '') {
            if(address != '') {
                address += ', ';
            }
            address += opportunity.ZIPCode__c.trim();
        }
        if(opportunity.City__c != null && opportunity.City__c.trim() != '') {
            if(address != '') {
                if(opportunity.ZIPCode__c == null || opportunity.ZIPCode__c.trim() == '') {
                    address += ', ';
                } else {
                    address += ' ';
                }
            }
            address += opportunity.City__c.trim();
        }
        if(opportunity.Country__c != null && opportunity.Country__c.trim() != '') {
            if(address != '') {
                address += ', ';
            }
            address += opportunity.Country__c.trim();
        }
        return address;
    }

    @TestVisible private String getMap(String address, String parentId) {
        String attId = null;
        String location = EncodingUtil.urlEncode(address, 'UTF-8');
        String mapFileName = 'GOOGLE_STATIC_MAP__' + location + '.png';
        Attachment oldAtt = null;

        List<Attachment> atts = [SELECT Id, Name FROM Attachment WHERE Name=:mapFileName OR ParentId=:parentId LIMIT 1];
        System.debug(atts);
        if(atts.size() > 0) {
            if(atts[0].Name != mapFileName) {
                // Delete old file if the location of current ID was modified
                oldAtt = atts[0];
            } else {
                attId = atts[0].Id;
            }
        }

        if(attId == null) {
            String mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?center='+location+'&zoom=15&markers=size:mid|color:0xf04414|'+location+'&size=800x515&scale=2&maptype=roadmap&key='+this.googleApiKey+'&format=png&visual_refresh=true';
            HttpRequest r = new HttpRequest();
            r.setMethod('GET');
            r.setEndpoint(mapUrl);
            Http http = new Http();
            HttpResponse res = http.send(r);
            blob image = res.getBodyAsBlob();

            System.debug(res);

            System.debug(res.getStatusCode());
            if(res.getStatusCode() == 200) {
                Attachment d = new Attachment();
                d.name = mapFileName;
                d.body = image;
                d.parentId = parentId;
                insert d;
                attId = d.Id;
            }
        }

        if(oldAtt != null) {
            delete oldAtt;
        }

        return attId;
    }

    public static String convertCurrencyFormat(Decimal dc, String unit) {
        return convertCurrencyFormat(dc, unit, null, false);
    }
    public static String convertCurrencyFormat(Decimal dc, String unit, String currencyCode) {
        return convertCurrencyFormat(dc, unit, currencyCode, false);
    }
    public static String convertCurrencyFormat(Decimal dc, String unit, String currencyCode, Boolean onlyNumber) {
        if(unit == null) {
            unit = '';
        }
        if(currencyCode == null) {
            currencyCode = '';
        }
        if(unit == 'K') {
            dc = dc/1000;
        } else if(unit == 'M') {
            dc = dc/1000000;
        }
        if (dc == null) return currencyCode + ' ' + '0.00';
        String s = (dc.setScale(2) + (dc > 0 ? 0.001 : -0.001)).format();
        String result = '';
        if(onlyNumber) {
            result = s.substring(0, s.length() - 1);
        } else {
            result = currencyCode + ' ' + s.substring(0, s.length() - 1) + ' ' + unit;
        }
        return result.trim();
    }

}