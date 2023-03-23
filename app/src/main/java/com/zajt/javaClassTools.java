package com.zajt;
import java.util.*;
import java.lang.reflect.*;
import com.zajt.MainjavaTools;
import com.luajava.LuaFunction;
import com.luajava.LuaObject;
import javax.microedition.khronos.*;
public class  javaClassTools extends MainjavaTools
{

	public   static List<String>   getClassAttribute(Class cls)
	{

		List<String> arrayx = new ArrayList<String>();

        //得到所有属性
        Field[] fields = cls.getDeclaredFields();
        for (int i = 0; i < fields.length; i++)
		{//遍历

			//得到属性
			Field field = fields[i];
			//打开私有访问
			field.setAccessible(true);
			//获取属性
			String name = field.getName();
			//获取属性值
			arrayx.add(field.getName());

		}
		return arrayx;
	}
	public  static boolean isObjectClass(Class cls, Object obj)
	{
		if (obj.getClass().getName() == "java.lang.Class")
		{
			throw new RuntimeException("Type error");
		}
		else
		{
			return  obj.getClass() == cls;
		}
	}

	/*public static Class newSubClass()
	{
		return null;
	}*/




	public static List<String>   getObjectClassAttribute(Object obj)
	{
		List<String> arrayx = new ArrayList<String>();

        String nameVlues = "";
		Class cls=obj.getClass();
        //得到所有属性
        Field[] fields = cls.getDeclaredFields();
        for (int i = 0; i < fields.length; i++)
		{//遍历

			//得到属性
			Field field = fields[i];

			//打开私有访问
			field.setAccessible(true);
			//获取属性
			String name = field.getName();
			//获取属性值

			arrayx.add(field.getName());

		}
		return arrayx;
	}
	public static List<String> getObjectClassMethod(Object objsnmae)
	{
		Class clsss=objsnmae.getClass();
		return getClassMethodName(clsss, false);
	}

	public static List<String> getClassMethodName(Class clsname, boolean isppublicno)
	{

		List<String> clsMethodname = new ArrayList<String>();
        Class<String> stringClass = clsname;
        // 获取所有的 public 修饰的方法，包括父类的。
        Method[] methods = stringClass.getMethods();
        // 获取声明是所有本类的方法（不包括父类的）
		Method[] declaredMethods = stringClass.getDeclaredMethods();
        for (int i = 0; i < methods.length; i++)
		{


            Method method = methods[i];


			clsMethodname.add(method.getName());

        }
		return clsMethodname;
	}
	public boolean isMethod(Class clzz, String methodName, Class[] argsType)
	{
		// 从当前类查找
        try
		{
            Method declaredMethod = clzz.getDeclaredMethod(methodName, argsType);
            if (declaredMethod != null)
			{
                return true;
            }
        }
		catch (NoSuchMethodException e)
		{
        }
        // 从父类中查找
        try
		{
            Method method = clzz.getMethod(methodName, argsType);
            if (null != method)
			{
                return true;
            }
        }
		catch (NoSuchMethodException e)
		{
        }
        return false;
	}
	public static String[] getMethodArray(Class clsname)
	{
        Class<String> stringClass = clsname;
        // 获取所有的 public 修饰的方法，包括父类的。
        Method[] methods = stringClass.getMethods();
		String[] clsMethodname = new String[methods.length];
        // 获取声明是所有本类的方法（不包括父类的）
		//Method[] declaredMethods = stringClass.getDeclaredMethods();
        for (int i = 0; i < methods.length; i++)
		{
            Method method = methods[i];
			clsMethodname[i] = method.getName();
        }
		return clsMethodname;
	}
	public static boolean  isMethod(Class clsname, String MethodName)
	{
        Class<String> stringClass = clsname;
        // 获取所有的 public 修饰的方法，包括父类的。
        Method[] methods = stringClass.getMethods();
        for (int i = 0; i < methods.length; i++)
		{
            Method method = methods[i];

			if (method.getName() == MethodName)
			{
				return true;
			}
        }
		return false;
	}


}
