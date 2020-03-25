@isTest
public class Contactsextension_TEST {
    /**
    * Test cases for rigth image types and a wrong type
    */
    @isTest
    public static void testImageTypes(){
		TestUtilities tu = TestUtilities.generateTest();
		
        ApexPages.StandardController sc;
        Contactsextension cTest;
        
        Contact myContact = tu.aContac;
    
        List<String> types = new List<String>{'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
    
        Attachment tempAtt = new Attachment();
        
        Test.startTest();
            for( String aType: types ){
                sc = new ApexPages.StandardController(myContact);
                cTest = new Contactsextension( sc );
                cTest.newAttach.Name = 'Picture-' + sc.getId();
                cTest.newAttach.Body = Blob.valueOf('String');
                cTest.newAttach.ContentType = aType;
                cTest.uploadAction();
                
                cTest.newAttach.Body = Blob.valueOf('String');
                
                System.assert( cTest.newAttach.name == 'Contact Picture', 'Name not equals' );
                System.assert( cTest.newAttach.ContentType == aType, 'Types not equals' );
                        
            }

            sc = new ApexPages.StandardController(myContact);
            cTest = new Contactsextension( sc );
            cTest.newAttach.Name = 'Picture-' + sc.getId();
            cTest.newAttach.Body = Blob.valueOf('String');
            cTest.newAttach.ContentType = 'image/YYY';
            cTest.uploadAction();
            System.assert( cTest.error == 'The image must be .jpg, .gif or .png<br/>', 'Error in error message.' + cTest.error);

            cTest = new Contactsextension( sc );
            cTest.uploadAction();
            
        Test.stopTest();
    } 
    
    /**
    *Test upload picture with no picture at the start.
    *
    */
    @isTest
    public static void testNoPicture(){
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );
        Contactsextension cTest = new Contactsextension( sc );
        cTest.newAttach.Name = 'Picture-' + sc.getId();
        cTest.newAttach.Body = Blob.valueOf('String');
        cTest.newAttach.ContentType = 'image/jpeg';
        cTest.uploadAction();

        Attachment attUploaded = [ SELECT name, parentId, body, ContentType FROM Attachment WHERE parentId =: sc.getId() AND name = 'Contact Picture'];
        System.assert( attUploaded != null, 'No attachment uploaded.' );
        System.assert( attUploaded.name == 'Contact Picture', 'Name not equals.' );
        System.assert( attUploaded.Body.toString() == Blob.valueOf('String').toString(), 'Bodys not equals.' );
        System.assert( attUploaded.ContentType == 'image/jpeg', 'Types not equals.' );

        
        // Replace string
        sc = new ApexPages.StandardController( tu.aContac );
        cTest = new Contactsextension( sc );
        cTest.newAttach.Name = 'Picture-' + sc.getId();
        cTest.newAttach.Body = Blob.valueOf('Other String For Replacement');
        cTest.newAttach.ContentType = 'image/png';
        cTest.uploadAction();
        
        attUploaded = [ SELECT name, parentId, body, ContentType FROM Attachment WHERE parentId =: sc.getId() AND name = 'Contact Picture'];
        System.assert( attUploaded != null, 'No attachment uploaded.' );
        System.assert( attUploaded.name == 'Contact Picture', 'Name not equals.' );
        System.assert( attUploaded.Body.toString() == Blob.valueOf('Other String For Replacement').toString(), 'Bodys not equals.' );
        System.assert( attUploaded.ContentType == 'image/png', 'Types not equals.' );
        
        
        Id stroringAttIdForRetreve = cTest.newAttach.id;
        cTest = new Contactsextension( sc );
        cTest.deleteAction();
        List<Attachment> attUploadedList = [ SELECT id FROM Attachment WHERE id =: stroringAttIdForRetreve ];
       Test.stopTest();    
 
        System.assert( attUploadedList.size() == 0, 'Attachment not deleted !!!' );
        
    }
    
    /**
    * Code coverage for cancel action
    */
    @isTest
    public static void testCancelAction(){
        TestUtilities tu = TestUtilities.generateTest();
        
        Test.startTest();
	        ApexPages.StandardController sc = new ApexPages.StandardController( tu.aContac );
	        Contactsextension cTest = new Contactsextension( sc );
	        cTest.cancel();         
       Test.stopTest();
 	        System.assert( cTest.cancel() != null, 'Some error occurs with PageReference Method is called' );
    }

}