# Creating Custom Aspects: An Introduction

In the previous messages of this e-mail course, we have seen several pre-built aspects available through downloadable libraries. However, it is not always possible to cater to every scenario developers may encounter. It's time to learn how to craft your own aspects. Since most pre-built aspects are open source, this will also give you the skills to bend them to your specific needs.

## What can an aspect do?

You can think of aspects as units of compile-time behavior that can do three things:
1. Generate code
2. Report errors and warnings
3. Suggest code fixes or refactorings, often as a remediation to an error or warning.

_Code generation_ is by far the most complex area. Here are the different kinds of transformations you can perform to code using Metalama:

- Override existing members
- Introduce new members into an existing type
- Implement interfaces into an existing type
- Adding custom attributes
- Adding class or instance initializers
- Adding parameters to an existing constructor and pulling them from upstream constructors
- Adding validation or normalization logic to parameters or return values

Let's start today with the most useful kind of code generation: overriding existing members.

## Different kinds of member overrides

Metalama comes with several abstract classes depending on the kind of member you want to override.

For __methods__, create a class that derives from the `OverrideMethodAspect` class.

```c#
using Metalama.Framework.Aspects;

internal class MyAspectAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        throw new NotImplementedException();
    }
}
```

For __fields or properties__, use the `OverrideFieldOrPropertyAspect` class.

```c#
using Metalama.Framework.Aspects;

internal class MyAspectAttribute : OverrideFieldOrPropertyAspect
{
    public override dynamic? OverrideProperty
    {
        get;
        set;
    }
}
```

Lastly, for __events__, use `OverrideEventAspect`.

```c#
using Metalama.Framework.Aspects;

internal class MyAspectAttribute : OverrideEventAspect
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

Each of these classes defines a set of abstract _templates_ that you must implement: `OverrideMethod`, `OverrideProperty` and `OverrideAdd`.  The code of these templates will _replace_ the code of the members to which you apply the templates. In these templates, you can use `meta.Proceed()` to invoke the _original_ code of the method. To access information about the overridden member, your template can use the API behind `meta.Target`. `meta` stands for meta-programming.

## Example: authorization

To give an example, let's consider a simplified authorization aspect, which aims to add a check to whichever method(s) we want to restrict to the user 'Mr Bojangles'. A check is made to ascertain who the current user is, and if that user someone else than Mr Bojangles, an exception is thrown.  Otherwise, we use `return meta.Proceed();` to proceed with the normal execution of the method.



```c#
using Metalama.Framework.Aspects;
using System.Security;
using System.Security.Principal;

internal class MyAspectAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        // Determine who the current user is
        var user = WindowsIdentity.GetCurrent().Name;

        if(user != "Mr Bojangles")
        {
            throw new SecurityException($"The '{meta.Target.Method}' method can only be called by Mr Bojangles");
        }

        // Carry on and execute the method
        return meta.Proceed();
    }
}
```

In practice, the custom aspect would be applied as an attribute on a method:

```c#
 [MyAspect]
 private static void HelloFromMrBojangles()
 {
     Console.WriteLine("Hello");
 }
```

When viewed with the 'Show Metalama Diff' tool, we can examine the code that will be added at compile time. This is an excellent way to verify that the custom aspects you create meet your requirements:

```c#
using System.Security;
using System.Security.Principal;

[MyAspect]
private static void HelloFromMrBojangles()
{
    var user = WindowsIdentity.GetCurrent().Name;

    if (user != "Mr Bojangles")
    {
        throw new SecurityException("The 'HelloFromMrBojangles()' method can only be called by Mr Bojangles");
    }
    
    Console.WriteLine("Hello");
}
```

While this is a simple example, it serves to illustrate that creating custom aspects should not be seen as a daunting task.

The Metalama Documentation provides comprehensive information on [creating custom aspects](https://doc.postsharp.net/metalama/conceptual/aspects).

