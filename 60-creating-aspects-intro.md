# Creating Custom Aspects: An Introduction

While Metalama offers a large number of pre-built aspects available through downloadable libraries, it's not possible to cater to every scenario that developers may encounter.

When a developer finds a situation where an aspect would be highly beneficial, but there isn't a pre-made one available, the solution is to create a custom aspect to meet the immediate need.

An aspect's function can be divided into two basic areas: adding additional code at compile time to provide a specific functionality, or to provide compile and pre-compile time validation of your codebase. The first step is to decide which part of the codebase the aspect should target.

If we want to target types in the codebase, the basic signature of a custom aspect would look like this:

```c#
using Metalama.Framework.Aspects;

    internal class CustomAspectAttribute : TypeAspect
    {
    }
```

If methods are our target, then the signature would look like this:

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

> <b>Note that we must implement the abstract base OverrideMethod() </b>

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

Finally, targeting events would require the following:

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

Having decided what to target, we need to decide what to do next. In this very basic introduction to creating custom aspects, let's focus on targeting a method. A common requirement is to restrict access to methods to certain users. The code below is a very basic implementation of that:

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

In the example above, we want to add a check to whichever method(s) we want to be restricted to the user 'Mr Bojangles'. A check is made to ascertain who the current user is and, if that user is indeed Mr Bojangles, the method is run. That's the purpose of the special return statement `return meta.Proceed();`. If the condition isn't met, an exception is thrown.

In use, the custom aspect would be applied as an attribute on a method:

```c#
 [CustomAspect]
 private static void HelloFromMrBojangles()
 {
     Console.WriteLine("Hello");
 }
```

When viewed with the 'Show Metalama Diff' tool, we can examine the code that will be added at compile time. This is a great way to check that the custom aspects you create actually meet your requirements:

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

This admittedly simple example still serves to illustrate that creating custom aspects shouldn't be seen as a daunting task.

The Metalama Documentation has a lot of information on [creating custom aspects](https://doc.postsharp.net/metalama/conceptual/aspects).


If you'd like to learn more about Metalama in general, visit our [website](https://www.postsharp.net/metalama).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
