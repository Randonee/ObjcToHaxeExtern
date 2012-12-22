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
		var parentClass:Clazz = getClassForType(clazz.parentClassName);
	
		if(parentClass != null)
		{
			if(parentClass.methods.exists(method))
				return true;
			else
				return isMothodDefinedInSuperClass(method, parentClass);
		}
		return false;
	}
	
	public function getClassForType(type:String):Clazz
	{
		if(items.exists(type))
			return items.get(type);
			
		for(clazz in items)
		{
			for(a in 0...clazz.classesInSameFile.length)
			{
				if(clazz.classesInSameFile[a].name == type)
					return clazz.classesInSameFile[a];
				
			}
			
			for(b in 0...clazz.structures.length)
			{
				if(clazz.structures[b].name == type)
					return clazz;
			}
			
			for(b in 0...clazz.enumerations.length)
			{
				if(clazz.enumerations[b].name == type)
					return clazz;
			}
		}
		return null;
	}
	
	public function getHoldingClassForType(type:String):Clazz
	{
		if(items.exists(type))
			return items.get(type);
			
		for(clazz in items)
		{
			for(a in 0...clazz.classesInSameFile.length)
			{
				if(clazz.classesInSameFile[a].name == type)
					return clazz;
			}
			
			for(b in 0...clazz.structures.length)
			{
				if(clazz.structures[b].name == type)
					return clazz;
			}
			
			for(b in 0...clazz.enumerations.length)
			{
				if(clazz.enumerations[b].name == type)
					return clazz;
			}
		}
			
		return null;
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