# Creating Custom Aspects: An Introduction

Whilst Metalama has a large number of pre-built aspects (available through downloadable libraries) it is impossible to cater for every scenario that developers' may want to cover.

When a developer comes across a situation where an aspect would be extremely beneficial but there isn't a ready made one available then the solution is to create a custom aspect to fulfil the immediate requirement.

The function of an aspect is can be divided into two basic areas, adding additional code at compile time to provide a particular functionality or to provide compile and pre-compile time validation of your codebase. The first thing to do then is to decide which part of the codebase the aspect is to target.

If we want to target types in the codebase then the basic signature of a custom aspect would look like this.

```c#
using Metalama.Framework.Aspects;

    internal class CustomAspectAttribute : TypeAspect
    {
    }
```

If methods were our target then the signature would be like this.

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

> <b>Notice that we must implement the abstract base OverideMethod() </b>

Field or property targets would lead us to this.

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

Finally targeting events would require the following.

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

Having decided what to target what needs to be done next. In this very basic od introductions to creating custom aspects let's work on targeting a method. A not uncommon requirement is to restrict access to methods to certain users. Below is a very basic implementation of that.

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

In the above we want to add a check to whichever method(s) we want to be restricted to the user 'Mr Bojangles'. A check is made to ascertain who the current user is and if that user is in fact Mr Bojangles the method is run, that is the purpose of the special return statement `return meta.Proceed();`. If the condition isn't met an exception is thrown.

In use the custom aspect would be applied as an attribute on a method.

```c#
 [CustomAspect]
 private static void HelloFromMrBojangles()
 {
     Console.WriteLine("Hello");
 }
```

When looked at with the 'Show Metalama Diff' tool we can examine the code that will be added at compile time. This is a very good way to check that custom aspects that you create actually fulfil your requirements.

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

This is a very simple example of creating an aspect that affects methods. It does illustrate though that creating aspects for your own custom use shouldn't be seen as a daunting task.

The Metalama Documentation has a lot of information on [creating custom aspects](https://doc.postsharp.net/metalama/conceptual/aspects).

<br>

If you'd like to know more about Metalama in general then visit our [website](https://www.postsharp.net/metalama).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
