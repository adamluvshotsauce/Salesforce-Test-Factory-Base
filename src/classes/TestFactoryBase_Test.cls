@isTest
private class TestFactoryBase_Test {

	static String testDef = 'TestFactoryBase.TestBaseDef';

	static TestFactoryBase base = new TestFactoryBase();
	
	@isTest static void testBuildSObject() {
		Account account = (Account)base.buildSObject(new Account());
		System.assertEquals(null, account.Id);
	}
	
	@isTest static void testBuildSObjectWithDefinitionName() {
		Account account = (Account)base.buildSObject(new Account(Name = 'Test Account'), testDef);
		System.assertEquals(null, account.Id);
	}
	
	@isTest static void testBuildSObjectList() {
		List<Account> accounts = base.buildSObjectList(new Account(), 10);
		System.assertEquals(10, accounts.size());
		System.assertEquals(null, accounts[0].Id);
	}
	
	@isTest static void testBuildSObjectListWithDefinitionName() {
		List<Account> accounts = base.buildSObjectList(new Account(), 10, testDef);
		System.assertEquals(10, accounts.size());
		System.assertEquals(null, accounts[0].Id);
	}
	
	@isTest static void testCreateSObject() {
		Account account = (Account)base.createSObject(new Account(Name = 'Test Account'));
		System.assertNotEquals(null, account.Id);
	}
	
	@isTest static void testCreateSObjectWithDefinitionName() {
		Account account = (Account)base.createSObject(new Account(Name = 'Test Account'), testDef);
		System.assertNotEquals(null, account.Id);
	}
	
	@isTest static void testCreateSObjectList() {
		List<Account> accounts = base.createSObjectList(new Account(Name = 'Test Account'), 10);
		System.assertEquals(10, accounts.size());
		System.assertNotEquals(null, accounts[0].Id);
	}
	
	@isTest static void testCreateSObjectListWithDefinitionName() {
		List<Account> accounts = base.createSObjectList(new Account(Name = 'Test Account'), 10, testDef);
		System.assertEquals(10, accounts.size());
		System.assertNotEquals(null, accounts[0].Id);
	}
	
	@isTest static void testInvalidDefinitionName() {
		try {
			Account account = (Account)base.buildSObject(new Account(), 'InvalidDef');
		} catch (TestFactoryBase.TestFactoryException ex) {
			System.debug('>>>>>>>>>>>> Custom exception for invalid object defintion: ' + ex);
			// Assert the invalid definition is not an object definition
			System.assertEquals(null, Type.forName('TestAccountFactory.InvalidDef'));
		}
	}
}