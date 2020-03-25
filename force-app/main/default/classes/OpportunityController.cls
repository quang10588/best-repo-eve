public with sharing class OpportunityController {
    public OpportunityController() {

    }

    @AuraEnabled
    public static void updateVersion(String opportunityId) {
        System.debug(opportunityId);
        Date now = Date.today();
        Opportunity o = [SELECT Id, Version_date_1__c, Version_date_2__c, Version_date_3__c FROM Opportunity WHERE Id = :opportunityId];
        Integer version_number = 1;
        if(o.Version_date_1__c == null || o.Version_date_1__c == now) {
            o.Version_date_1__c = now;
        } else if(o.Version_date_2__c == null || o.Version_date_2__c == now) {
            o.Version_date_2__c = now;
            version_number = 2;
        } else {
            o.Version_date_3__c = now;
            version_number = 3;
        }
        update o;

        savePdf(opportunityId, version_number);
    }

    @future(callout=true) 
    private static void savePdf(String opportunityId, Integer version_number) {

        PageReference pdf = Page.PDFGenerator;
        pdf.getParameters().put('id', opportunityId);
        
        Blob body;
        try {
            body = pdf.getContentAsPDF();
        } catch (VisualforceException e) {
            body = Blob.valueOf('Get pdf file error: ' + e.getMessage());
        }

        Set<Id> docIds = new Set<Id>();
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:opportunityId];
        for(ContentDocumentLink c:contentDocumentLinks) {
            docIds.add(c.ContentDocumentId);
        }

        String contentDocumentId = null;
        if(docIds.size() > 0) {
            String docKey = 'FP_v'+version_number+'%';
            List<ContentVersion> contentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :docIds AND Title LIKE :docKey LIMIT 1];
            if(contentVersions.size() == 1) {
                contentDocumentId = contentVersions[0].contentDocumentId;
            }
        }

        String fileName = System.Label.pdf_version_generator_pdf_filename_format;
        // Replace the number of version
        fileName = String.format(fileName,  new List<Integer> {version_number});
        // Replace the date
        Pattern filePattern = Pattern.compile('\\[(\\w+.*?)\\]');
        Matcher matcher = filePattern.matcher(fileName);
        String dateFormat = null;
        System.debug(matcher.groupCount());
        if (matcher.find() && matcher.groupCount() == 1) {
            fileName = fileName.replace(matcher.group(0), Datetime.now().format(matcher.group(1)));
        }

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = fileName;
        conVer.Title = fileName;
        conVer.VersionData = body;

        if(contentDocumentId != null) {
            conVer.ContentDocumentId = contentDocumentId;
        }

        insert conVer;

        if(contentDocumentId == null) {
            // First get the content document Id from ContentVersion
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = opportunityId; // you can use objectId,GroupId etc
            cDe.ShareType = 'V';
            insert cDe;
        }

    }
}