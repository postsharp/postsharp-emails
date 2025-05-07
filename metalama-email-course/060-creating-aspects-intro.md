---
subject: Introduction to Creating Custom Aspects
---


In the previous segments of this e-mail course, we explored several pre-built aspects available through downloadable libraries. However, the diverse scenarios developers face may not always be addressed by these pre-built aspects. Therefore, it's time to learn how to create your own aspects. Since most pre-built aspects are open source, this knowledge will also enable you to customize them to suit your specific needs.

## What Can an Aspect Do?

Aspects can be thought of as units of compile-time behavior capable of performing three main tasks:
1. Generating code
2. Reporting errors and warnings
3. Suggesting code fixes or refactorings, typically as a remediation for an error or warning.

_Code generation_ is undoubtedly the most complex area. Below are the different types of transformations you can apply to code using Metalama:

- Overriding existing members
- Introducing new members into an existing type
- Implementing interfaces in an existing type
- Adding custom attributes
- Adding class or instance initializers
- Adding parameters to an existing constructor and propagating them through upstream constructors
- Adding validation or normalization logic to parameters or return values
- Introducing new types (nested or top-level)

Let’s start with the most commonly used type of code generation: overriding existing members.

## Abstract Types for Member Overrides

Metalama provides several abstract classes depending on the type of member you want to override.

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

Lastly, for __events__, use the `OverrideEventAspect` class.

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

Each of these classes defines a set of abstract _templates_ that you must implement: `OverrideMethod`, `OverrideProperty`, and `OverrideAdd`. The code in these templates will _replace_ the code of the members to which you apply the templates. Within these templates, you can use `meta.Proceed()` to invoke the _original_ code of the method. To access information about the overridden member, your template can use the API behind `meta.Target`. Here, `meta` stands for meta-programming.

## Example: Authorization

To illustrate, let’s consider a simplified authorization aspect. This aspect adds a check to restrict access to specific methods to the user 'Mr Bojangles'. If the current user is not 'Mr Bojangles', an exception is thrown. Otherwise, the method proceeds with its normal execution using `return meta.Proceed();`.

```c#
using Metalama.Framework.Aspects;
using System.Security;
using System.Security.Principal;

internal class MyAspectAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        // Determine the current user
        var user = WindowsIdentity.GetCurrent().Name;

        if (user != "Mr Bojangles")
        {
            throw new SecurityException($"The '{meta.Target.Method}' method can only be called by Mr Bojangles.");
        }

        // Proceed with the method execution
        return meta.Proceed();
    }
}
```

In practice, the custom aspect is applied as an attribute on a method:

```c#
[MyAspect]
private static void HelloFromMrBojangles()
{
    Console.WriteLine("Hello");
}
```

Using the 'Show Metalama Diff' tool, you can examine the code that will be added at compile time. This is an excellent way to verify that your custom aspects meet your requirements:

```c#
[MyAspect]
private static void HelloFromMrBojangles()
{
    var user = WindowsIdentity.GetCurrent().Name;

    if (user != "Mr Bojangles")
    {
        throw new SecurityException("The 'HelloFromMrBojangles()' method can only be called by Mr Bojangles.");
    }

    Console.WriteLine("Hello");
}
```

While this is a simple example, it demonstrates that creating custom aspects is not as daunting as it may seem.

The Metalama Documentation provides comprehensive information on [creating custom aspects](https://doc.metalama.net/conceptual/aspects).
