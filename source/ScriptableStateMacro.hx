package;
import haxe.macro.Context;
import haxe.macro.Expr;
class ScriptableStateMacro {
  public static function build():Array<Field> {
	// get existing fields from the context from where build() is called
	var fields = Context.getBuildFields();
	for (i => v in fields){
		// trace('$i - $v');
		var myFunc:Function = { 
		  expr: macro return $v{value},  // actual value
		  ret: (macro:Float), // ret = return type
		  args:[] // no arguments here
		}
		fields.push({
			name: "get_" + i,
			access: [Access.APublic, Access.AOverride],
			kind: FieldType.FFun(myFunc),
			pos: pos,
		});
	}
	
	// var value = 1.5;
	// var pos = Context.currentPos();
	// var fieldName = "myVar";
	
	// var myFunc:Function = { 
	//   expr: macro return $v{value},  // actual value
	//   ret: (macro:Float), // ret = return type
	//   args:[] // no arguments here
	// }
	
	// // create: `public var $fieldName(get,null)`
	// var propertyField:Field = {
	//   name:  fieldName,
	//   access: [Access.APublic],
	//   kind: FieldType.FProp("get", "null", myFunc.ret), 
	//   pos: pos,
	// };
	
	// // create: `private inline function get_$fieldName() return $value`
	// var getterField:Field = {
	//   name: "get_" + fieldName,
	//   access: [Access.APrivate, Access.AInline],
	//   kind: FieldType.FFun(myFunc),
	//   pos: pos,
	// };
	
	// // append both fields
	// fields.push(propertyField);
	// fields.push(getterField);
	
	return fields;
  }
}