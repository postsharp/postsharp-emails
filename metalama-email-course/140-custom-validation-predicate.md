---
subject: "Validating Architecture on Your Terms: Custom Predicates"
---

In previous discussions, we explored how Metalama provides several pre-built fabric extension methods to help validate the architecture of your codebase. However, there may be scenarios where these pre-built methods do not fully meet your requirements, necessitating custom validation.

Metalama offers various methods for architecture validation, such as `CanOnlyBeUsedFrom`, `CannotBeUsedFrom`, `InternalsCanOnlyBeUsedFrom`, and `InternalsCannotBeUsedFrom`. These methods accept predicates like `Assembly(name)`, `CurrentNamespace()`, `Namespace(name)`, `NamespaceOf(type)`, `Type(type)`, or `HasFamilyAccess`, all exposed as extension methods of the [ReferencePredicateBuilder](https://doc.metalama.net/api/metalama-extensions-architecture-predicates-referencepredicatebuilder) class. Before creating your own validation methods, consider whether you can use these methods with a custom predicate. This is the approach we will explore in this article.

## 1. Create a Predicate Class

The first step is to create a class derived from the `ReferencePredicate` abstract class and implement its `IsMatch` method. While implementing a class instead of supplying a delegate may seem cumbersome at first, it is necessary because predicates must be serializable to validate references from other projects.

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
///    This class defines the predicate. It checks method names to determine if,
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

The next step is to create a public extension method for your predicate.

```cs
/// <summary>
///   A class to expose your custom extensions.
/// </summary>
/// <remarks>
///   This class serves as an API for your extensions.
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
        // Validate that methods within a certain type (in this case, CoffeeMachine)
        // can only be called from methods whose names end with "Politely".
        amender
        .SelectTypes(typeof(CoffeeMachine))
        .CanOnlyBeUsedFrom(r => r.MethodNameEndsWith("Politely"));
    }
}
```

```cs
// A proud coffee machine. This is the class whose method(s) we wish to validate.
internal static class CoffeeMachine
{
    public static void TurnOn()
    {
    }
}

// A test class to verify the new predicate.
internal class Bar
{
    public static void OrderCoffee()
    {
        // This call to CoffeeMachine is reported because the method is not polite enough.
        CoffeeMachine.TurnOn();
    }

    public static void OrderCoffeePolitely()
    {
        // This call to CoffeeMachine is accepted because the method is polite.
        CoffeeMachine.TurnOn();
    }
}
```

The functionality of this code extension is demonstrated in the GIF below.

![](images/refpredicate.gif)
