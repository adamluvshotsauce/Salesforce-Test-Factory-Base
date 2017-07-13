# Salesforce Test Factory Base

Usage:
    
    // Instantiate a new instance of the base factory
    TestFactoryBase base = new TestFactoryBase();

    // The Base Factory will attempt to pre-fill all the fields that are 
    // required and typically used for a specific SObject 
    Account acct = (Account)base.buildSObject(new Account());
    insert acct;

    // You can also assign values into the object constructor which will 
    // override the defaults.
    //
    // This also works when you are requesting a specific ObjectDefinition!!
    Contact con = (Contact)base.createSObject(new Contact(AccountId = acct.Id));

    // You can also specify a specific set of overrides to define the shape of an object
    Account customer = (Account)base.createSObject(new Account(), 'CustomerDef');

    // You can also specify a number of records you'd like to create 
    List<Account> accts = base.createSObjectList(new Account(), 200);
    
    /*********************************************************************************************** 
    *   Build vs Create Methods
    ***********************************************************************************************/

    // Build methods will setup and return the object(s) without inserting it
    Account acct = (Account)base.buildSObject(new Account());

    // Create methods will setup and insert the object(s) thats returned
    Account acct = (Account)base.createSObject(new Account());

    /*********************************************************************************************** 
    *   Name Field Map configuration
    ***********************************************************************************************/

    // Update the map with SObject => Field API Name pairing for special objects that don't have a
    // standard Name field or have an auto numbered Name field for incrementing in bulk requests
    private Map<String, String> nameFieldMap = new Map<String, String> {
        'Contact' => 'LastName',
        'Case'    => 'Subject'
    };

    /*********************************************************************************************** 
    *   TestFactoryBase is a virtual class so it's also extendable
    ***********************************************************************************************/

    // You can use it to borrow Base test methods in existing or new 
    // object test factories
    public class AccountTestFactory extends TestFactoryBase {}

    // You can leverage the same Factory Base methods from the object test factory
    AccountTestFactory acctFactory = new AccountTestFactory();
    Account acct = (Account)acctFactory.buildSObject(new Account());

    /***********************************************************************************************  
    *   You can also build your own object configurations by implementing
    *   the ObjectDefinition interface and storing the class into the
    *   associated [SObject]TestFactory.
    *
    *   NOTE: Each ObjectDefinition should end with the 'Def' suffix
    *         in order for the framework to identify the appropriate
    *         definition.
    ***********************************************************************************************/

    public class CustomerDef implements ObjectDefinition {
        public Map<String, Object> getDefinition() {
            return new Map<String, Object> {
                'Name'         => 'Test Customer',
                'Type'         => 'Customer',
                'RecordTypeId' => AccountConstants.RECORD_TYPE_CUSTOMER_ID
            };
        }
    }
