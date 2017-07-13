public virtual class TestFactoryBase {

  /***********************************************************************************************
  *
  * Private Attributes
  *
  ***********************************************************************************************/
  // When we create a list of SObjects, we need to specify the Name field for enforcing
  // uniqueness amongst each object
  private Map<String, String> nameFieldMap = new Map<String, String> {
    'Contact' => 'LastName',
    'Case'    => 'Subject'
  };

  private static final String definitionSuffix  = 'Def';
  private static final String testFactoryPrefix = 'TestFactory';
  private static final String nameString        = 'Name';

  /***********************************************************************************************
  *
  * Public Methods
  *
  ***********************************************************************************************/
  public SObject buildSObject(SObject sObj) {
    String factoryName = getFactoryName(sObj);
    String definitionName = replaceUnderScores(sObj) + definitionSuffix;

    String factoryDefinitionName = String.join(new List<String>{factoryName, definitionName}, '.');

    if(Type.forName(factoryDefinitionName) != null) {
      return buildSObject(sObj, factoryDefinitionName);
    } else return sObj;
  }

  public SObject buildSObject(SObject sObj, String definitionName) {
  
    Type definition = Type.forName(definitionName);

    // Attempt to rebuild the definition if no class was found
    if (definition == null) {

      // Create the factory name for the SObject passed in
      String factoryName = getFactoryName(sObj);
      if (Type.forName(factoryName) == null) {
        Throw new TestFactoryException('Invalid test factory. There is no test factory created for that SObject.');
      }

      String factoryDefinitionName =
        String.join(new List<String>{factoryName, definitionName}, '.');

      // Create an instance of the ObjectDefinition so we can get the map of field definitions
      definition = Type.forName(factoryDefinitionName);
      if (definition == null) {
        Throw new TestFactoryException('Invalid object definition. Please check the SObject factory for the correct definition name.');
      }
    }

    ObjectDefinition objDef = (ObjectDefinition)definition.newInstance();
    addFieldDefinitions(sObj, objDef.getDefinition());
    return sObj;
  }

  public List<SObject> buildSObjectList(SObject sObj, Integer numberOfObjects) {
    List<SObject> retList = buildSObjectList(sObj, numberOfObjects, (String)null);
    return retList;
  }

  public List<SObject> buildSObjectList(SObject sObj, Integer numberOfObjects, String definitionName) {
    List<SObject> sObjs = new List<SObject>();
    SObject newObj;

    // Get one copy of the object
    if (definitionName == null) {
      newObj = buildSObject(sObj);
    } else {
      newObj = buildSObject(sObj, definitionName);
    }

    // Get the name field for the object
    String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
    if (nameField == null && isNameFieldAutoNumber(newObj)) {
      Throw new TestFactoryException('Auto number detected on Name field. Please register a different field in the name field map.');
  
    } else if(nameField == null) {
      nameField = nameString;
    } 

    // Clone the object the number of times requested. Increment the name field
    // so each record is unique
    for (Integer i = 0; i < numberOfObjects; i++) {
      SObject clonedSObj = newObj.clone(false, true);
      clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
      sObjs.add(clonedSObj);
    }
    return sObjs;
  }

  public SObject createSObject(SObject sObj) {
    SObject retObject = buildSObject(sObj);
    insert retObject;
    return retObject;
  }

  public SObject createSObject(SObject sObj, String definitionName) {
    SObject retObject = buildSObject(sObj, definitionName);
    insert retObject;
    return retObject;
  }

  public List<SObject> createSObjectList(SObject sObj, Integer numberOfObjects) {
    List<SObject> retList = buildSObjectList(sObj, numberOfObjects, (String)null);
    insert retList;
    return retList;
  }

  public List<SObject> createSObjectList(SObject sObj, Integer numberOfObjects, String definitionName) {
    List<SObject> retList = buildSObjectList(sObj, numberOfObjects, definitionName);
    insert retList;
    return retList;
  }

  /***********************************************************************************************
  *
  * Private Methods
  *
  ***********************************************************************************************/
  private void addFieldDefinitions(SObject sObj, Map<String, Object> defaults) {
    // Loop through the map of fields and if they are null on the object, fill them.
    for (String field : defaults.keySet()) {
      if (sObj.get(field) == null) {
        sObj.put(field, defaults.get(field));
      }
    }
  }

  private String getFactoryName(SObject sObj) {
    // Return the formatted SObject factory name
    String objectName = replaceUnderScores(sObj);
    return objectName + testFactoryPrefix;
  }

  private String replaceUnderScores(SObject sObj) {
    // Remove underscores as Salesforce doesn't allow '__' in class names
    return String.valueOf(sObj.getSObjectType()).replaceAll('__c|__', '');
  }

  private Boolean isNameFieldAutoNumber(SObject sObj) {
    // Check the SObject's field Name metadata and return if it is an auto number
    Schema.DescribeSObjectResult sobjResult        = sObj.getSObjectType().getDescribe();
    Map<String, Schema.SObjectField> sobjectFields = sobjResult.fields.getMap();
    Schema.DescribeFieldResult fieldResult         = sobjectFields.get(nameString).getDescribe();
    return fieldResult.isAutoNumber();
  }

  /***********************************************************************************************
  *
  * Inner Classes
  *
  ***********************************************************************************************/
  
  public class TestFactoryException extends Exception {}

  // Used only for test purposes
  public class TestBaseDef implements ObjectDefinition {
    public Map<String, Object> getDefinition() {
			return new Map<String, Object> {
				'Name' => 'Test Definition'
			};
		}
  }
}