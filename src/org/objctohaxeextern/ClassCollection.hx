package org.objctohaxeextern;

class ClassCollection
{
	public var items(default, null):Hash<Clazz>;
	
	public function new()
	{
		items = new Hash<Clazz>();
	}
	
	public function addClass(clazz:Clazz):Void
	{
		items.set(clazz.name, clazz);
	}
	
	
	public function isMothodDefinedInSuperClass(method:String, clazz:Clazz):Bool
	{
		if(items.exists(clazz.parentClassName))
		{
			var parentClass:Clazz = items.get(clazz.parentClassName);
			
			if(parentClass.methods.exists(method))
				return true;
			else
				return isMothodDefinedInSuperClass(method, parentClass);
		}
		return false;
	}
	
	public function isStaticMothodDefinedInSuperClass(method:String, clazz:Clazz):Bool
	{
		if(items.exists(clazz.parentClassName))
		{
			var parentClass:Clazz = items.get(clazz.parentClassName);
			
			if(parentClass.staticMethods.exists(method))
				return true;
			else
				return isStaticMothodDefinedInSuperClass(method, parentClass);
		}
		return false;
	}
	
}