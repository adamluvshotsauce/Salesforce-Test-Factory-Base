// To specify configurations for objects, use the naming convention [ObjectName]Def.
// For custom objects, omit the __c and any underscores from the Object Name
public interface ObjectDefinition {
	Map<String, Object> getDefinition();
}
