# Validating Architecture on Your Terms: Custom Predicates

In previous discussions, we have explored how Metalama provides a number of pre-built fabric extension methods to assist with validating the architecture of your codebase. However, there may be scenarios where these pre-built methods do not meet your requirements, necessitating the need for custom validation.

Metalama offers several methods for architecture validation, including `CanOnlyBeUsedFrom`, `CannotBeUsedFrom`, `InternalsCanOnlyBeUsedFrom` or `InternalsCannotBeUsedFrom`. These methods accept predicates such as `Assembly(name)`, `CurrentNamespace()`, `Namespace(name)`, `NamespaceOf(type)`, `Type(type)`, or `HasFamilyAccess`, all exposed as extension methods of the [ReferencePredicateBuilder](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-predicates-referencepredicatebuilder) class. Before creating your own validation methods, it may be beneficial to consider whether you could simply continue using these methods, but build a custom predicate. This is the approach we will take in this article.

## 1. Create a Predicate Class

The first step involves creating a class derived from the `ReferencePredicate` abstract class and implementing its `IsMatch` method. Implementing a class instead of supplying a delegate may seem cumbersome at first, but the reason is that predicates must be serializable for cases when the validation must apply to references from other projects.

We recommend keeping this predicate class internal.

```c#
using Metalama.Extensions.Architecture.Fabrics;
using Metalama.Extensions.Architecture.Predicates;
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using Metalama.Framework.Fabrics;
using Metalama.Framework.Validation;

/// <summary>
///    A method name predicate.
/// </summary>
/// <remarks>
///    This class creates the predicate. It's designed to  check method names and see if,
///    in this case, they end with a specific word or phrase.
/// </remarks>
internal class MethodNamePredicate : ReferencePredicate
{
    private readonly string _suffix;

    public MethodNamePredicate(ReferencePredicateBuilder? builder, string suffix) : base(builder)
    {
        this._suffix = suffix;
    }

    public override bool IsMatch(in ReferenceValidationContext context)
    {
        return context.ReferencingDeclaration is IMethod method &&
            method.Name.EndsWith(this._suffix, StringComparison.Ordinal);
    }
}
```
## 2. Create an Extension Method

The second step requires creating a public extension method for your predicate.

```cs
/// <summary>
///   A class to expose your custom extensions.
/// </summary>
/// <remarks>
///   This class can be thought of as a form of API for your extensions.
/// </remarks>
[CompileTime]
public static class Extensions
{
    public static ReferencePredicate MethodNameEndsWith(this ReferencePredicateBuilder? builder, string suffix)
        => new MethodNamePredicate(builder, suffix);
}
```

## 3. Use Your Extension Method in a Fabric

You can now use your predicate method in any fabric. In this example, let's assume a proud `CoffeeMachine` wants to be called only from methods whose names end with `Politely`.

```cs
/// <summary>
///  A project fabric, i.e., a compile-time entry point for your project.
/// </summary>
internal class Fabric : ProjectFabric
{
    public override void AmendProject(IProjectAmender amender)
    {
        // We'll be validating our code with a ProjectFabric. It will verify
        // that methods within a certain type (in this case CoffeeMachine) can
        // only be called from methods whose name ends with the word "Politely"
        amender
        .Verify()
        .SelectTypes(typeof(CoffeeMachine))
        .CanOnlyBeUsedFrom(r => r.MethodNameEndsWith("Politely"));
    }
}
```


```cs
// A proud coffee machine. This is the class whose method(s) we wish to verify.
internal static class CoffeeMachine
{
    public static void TurnOn()
    {
    }
}

// Our test class to verify our new predicate.
internal class Bar
{
    public static void OrderCoffee()
    {
        // The call to CoffeeMachine in this method is reported because the method is not polite enough.
        CoffeeMachine.TurnOn();
    }

    public static void OrderCoffeePolitely()
    {
        // This call to CofeeMachine is accepted because the method is polite.
        CoffeeMachine.TurnOn();
    }
}

```

The functionality of this code extension is demonstrated in the gif below.

![](images/refpredicate.gif)
