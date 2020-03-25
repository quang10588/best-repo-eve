/**
* @author Sebastian Munoz
* @createdDate 04/06/2010
*/
public with sharing class ShowPicture{

	public 	Attachment 	file 		{ set; get; }
	public 	Boolean 	hasPicture 	{ set; get; }
	private String		parentId 	{ set; get; }
	
	/**
	* Constructor
	*/
   	public ShowPicture( ApexPages.StandardController stdController ){
		
       	this.parentId 		= stdController.getId();
       	this.hasPicture 	= false;
       	       	
       	List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength 
       									From Attachment 
       									where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
       	if( attList.size() > 0 ){
       		this.file 		= attList.get( 0 );
       		this.file.Body 	= Blob.valueOf('AuxString');
       		this.hasPicture = true;
       	}
   	}	
}