@isTest

public class test 
{
    // Map for role ids and name
    // Map<Id,Role> roleIds = new Map<id,role>([SELECT Id]);
	public static UserRole userRoleRecord = [Select Id, Name From UserRole Where Name = 'ssyst Customer Person Account'];
	public static Map<String, Id> profileMap = new Map<String, Id>();    
    
    public static testMethod void fetchUserDetails()
    {
    	List <Profile> profileList = [Select Id, Name, UserLicenseId from Profile where UserLicenseId in (Select Id From UserLicense where Name = 'Customer Community Plus')];
    	for(Profile p: profileList)
    	{
    		profileMap.put(p.Name, p.Id);
    	}
    }
        
    public User createTestUser(Id roleId, Id profID, String fName, String lName)
    {
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstName = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'Perth/Australia',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId,
                                UserRoleId = roleId);
        return tuser;
    }
    
    public static void createInternalUser(String username)
    {
        String orgID = UserInfo.getOrganizationId();
        String profId = profileMap.get('GCVMS CDPH Staff');
        String roleId = userRoleRecord.Id;
        
        String fName = username.substringBefore('.');
        String temp = username.substringAfter('.');
        String lName = temp.substringBefore('@');
        
        User u = new User(	  FirstName = fName,
                              LastName = lName,
                              email = username + '.' + orgId,
                              Username = username + '.' + orgId,
                              TimeZoneSidKey = 'Australia/Perth',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId,
                              UserRoleId = roleId,
                          	  UserPermissionsInteractionUser = True
        );
        
        insert u;
        assignPermissionSets(u.Id);
        // system.assertEquals('wavms', u.FirstName);
        system.debug(u);
    }
    
    public static void assignPermissionSets(Id userId)
    {
        List <PermissionSetAssignment> permissionSetAssignments = new List <PermissionSetAssignment>();
        List <PermissionSet> permissionSetIds = [SELECT Id FROM PermissionSet Where Name IN ('WA_System_Data_Manager', 'Report_Access_Permission')];                
        
        for(PermissionSet t: permissionSetIds)
        {
        	PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = t.Id, AssigneeId = userId);
        	permissionSetAssignments.add(psa);
   		}
    
    	insert permissionSetAssignments;
    }
    
    public static testMethod void runAll()
    {
         createInternalUser('wavms.systemdatamanager@gmail.com');
         // createInternalUser('wavms.programofficer01@gmail.com');
    }
    
    
    
    
}