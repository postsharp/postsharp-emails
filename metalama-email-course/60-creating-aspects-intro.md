# Creating Custom Aspects: An Introduction

Metalama offers a wide array of pre-built aspects that are available through downloadable libraries. However, it is not always possible to cater to every scenario that developers may encounter.

In those instances where an aspect would be highly beneficial, but there isn't a pre-built one available, the solution is to create a custom aspect tailored to the specific need.

The functionality of an aspect can be broadly divided into two areas: adding additional code at compile time to provide specific functionality, and providing compile and pre-compile time validation of your codebase. The first step is to identify which part of the codebase the aspect should target.

If the aim is to target types in the codebase, the basic signature of a custom aspect would look like this:

```c#
using Metalama.Framework.Aspects;

    internal class CustomAspectAttribute : TypeAspect
    {
    }
```

If methods are the target, then the signature would look like this:

```c#
using Metalama.Framework.Aspects;

    internal class CustomAspectAttribute : OverrideMethodAspect
    {
        public override dynamic OverrideMethod()
        {
            throw new NotImplementedException();
        }
    }
```

> <b>Note: We must implement the abstract base OverrideMethod() </b>

For field or property targets, we would use this:

```c#
using Metalama.Framework.Aspects;

    internal class CustomAspectAttribute : OverrideFieldOrPropertyAspect
    {
        public override dynamic OverrideProperty
        {
            get;
            set;
        }

    }
```

Lastly, to target events, we would require the following:

```c#
using Metalama.Framework.Aspects;

    internal class CustomAspectAttribute : OverrideEventAspect
    {
        public override void OverrideAdd(dynamic value)
        {
            throw new NotImplementedException();
        }

        public override void OverrideRemove(dynamic value)
        {
            throw new NotImplementedException();
        }
    }
```

Once the target is decided, we need to determine the next steps. In this basic introduction to creating custom aspects, we will focus on targeting a method. A common requirement is to restrict access to methods to certain users. The code below is a basic implementation of that:

```c#
using Metalama.Framework.Aspects;
using System.Security;
using System.Security.Principal;


    internal class CustomAspectAttribute : OverrideMethodAspect
    {
        public override dynamic OverrideMethod()
        {
            // determine who the current user is
            var user = WindowsIdentity.GetCurrent().Name;

            if(user == "Mr Bojangles")
            {
                //carry on and execute the method
                return meta.Proceed();
            } else
            {
                throw new SecurityException("This method can only be called by Mr Bojangles");
            }
        }
    }
```

In the above example, we aim to add a check to whichever method(s) we want to restrict to the user 'Mr Bojangles'. A check is made to ascertain who the current user is, and if that user is indeed Mr Bojangles, the method is executed. This is the purpose of the special return statement `return meta.Proceed();`. If the condition isn't met, an exception is thrown.

In practice, the custom aspect would be applied as an attribute on a method:

```c#
 [CustomAspect]
 private static void HelloFromMrBojangles()
 {
     Console.WriteLine("Hello");
 }
```

When viewed with the 'Show Metalama Diff' tool, we can examine the code that will be added at compile time. This is an excellent way to verify that the custom aspects you create meet your requirements:

```c#
using System.Security;
using System.Security.Principal;

   [CustomAspect]
   private static void HelloFromMrBojangles()
   {
       var user = WindowsIdentity.GetCurrent().Name;
       if (user == "Mr Bojangles")
       {
           Console.WriteLine("Hello");

           return;
       }
       else
       {
           throw new SecurityException("This method can only be called by Mr Bojangles");
       }
   }
```

While this is a simple example, it serves to illustrate that creating custom aspects should not be seen as a daunting task.

The Metalama Documentation provides comprehensive information on [creating custom aspects](https://doc.postsharp.net/metalama/conceptual/aspects).

