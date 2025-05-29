---
subject: 'Get your development team to adhere to architecture'
---

Hi {{firstName}},

This is **{{sendingAccountFirstName}}** from Metalama. This is my final email in this series. In previous messages, I introduced Metalama's first pillar: code generation, using aspect-oriented programming. Today, I’m excited to introduce Metalama’s second pillar: architecture verification.

Unlike code generation and aspect-oriented programming, which are open source, architecture verification is a proprietary feature available with a [Metalama Professional](https://metalama.net/premium?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email5) license.

As you know, effective teamwork in software development depends on everyone following clear rules and conventions. This ensures that individual contributions integrate seamlessly into the overall application. Today, I’ll focus on two key areas:

- Enforcing naming conventions
- Enforcing usage and dependencies between components

## Enforcing Naming Conventions

If you’ve ever struggled to align your team on naming conventions, you’re not alone. With Metalama, you can define rules and conventions in plain C#, and they’ll be enforced both in real time in the IDE and at compile time.

For example, suppose you want every class implementing `IInvoiceFactory` to have the `InvoiceFactory` suffix. You can enforce this with a single attribute:

```csharp
[DerivedTypesMustRespectNamingConvention( "*InvoiceFactory" )]
public interface IInvoiceFactory
{
    Invoice CreateFromOrder( Order order );
}
```

If someone violates this rule, a warning is reported immediately:

```
LAMA0903. The type ‘MyInvoiceConverter’ does not respect the naming convention set on the base class or interface ‘IInvoiceFactory’. The type name should match the "*InvoiceFactory" pattern.
```

## Enforcing Architecture Rules

Now, let’s look at how to ensure components are used as intended. Maybe you’ve written a method meant only for testing. How do you prevent it from being used in production code?

- Option 1: Add a comment like **DO NOT USE IN PRODUCTION CODE!** and hope for the best.
- Option 2: Rely on code reviews—slow, frustrating, and error-prone.
- Option 3: Make your architecture _executable_ so rules are enforced automatically, right in the editor. That’s where Metalama shines.

The [Metalama.Extensions.Architecture](https://www.nuget.org/packages/Metalama.Extensions.Architecture) package provides a set of custom attributes and compile-time APIs to help teams enforce common conventions.

### Declarative Rules with Custom Attributes

Suppose you have a constructor that tweaks behavior for testing. You want to ensure it’s only used in test code. Metalama provides the [CanOnlyBeUsedFrom](https://doc.metalama.net/api/metalama-extensions-architecture-aspects-canonlybeusedfromattribute?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email5) attribute for this:

```csharp
using Metalama.Extensions.Architecture.Aspects;

namespace CommonTasks.ValidatingArchitecture
{
    public class OrderShipping
    {
        private bool isTest;

        public OrderShipping()
        {
        }

        [CanOnlyBeUsedFrom(Namespaces = new[] {"**.Tests"})]
        public OrderShipping(bool isTest)
        {
            // Used to trigger specific test configuration
            this.isTest = isTest;
        }
    }
}
```

If you try to use this constructor outside a namespace ending with `Tests`, you’ll see a warning.

![](images/ValidationWarning.jpg)

### Programmatic Rules with Compile-Time APIs

Imagine a project with many components, each in its own namespace, but not in separate projects. You want to ensure `internal` members are only accessible within their own namespace (except for test code).

With Metalama, you can validate each namespace by adding a _fabric_ type—a compile-time class that runs in the compiler or IDE:

```csharp
namespace MyComponent
{
    internal class Fabric : NamespaceFabric
    {
        public override void AmendNamespace(INamespaceAmender amender)
        {
            amender.InternalsCanOnlyBeUsedFrom(from =>
                from.CurrentNamespace().Or(or => or.Type("**.Tests.**")));
        }
    }
}
```

Now, if code outside the `MyComponent` namespace tries to access an internal API, a warning is reported.

In addition to `InternalsCanOnlyBeUsedFrom`, the package includes `InternalsCannotBeUsedFrom`, `CanOnlyBeUsedFrom`, and `CannotOnlyBeUsedFrom`. You can easily build more rules based on your code model.

## Conclusion

We’ve just seen two ways to validate your codebase using Metalama’s pre-built aspects and compile-time APIs.

Enforcing rules and conventions this way allows you to:

- Eliminate the need for lengthy written guidelines
- Provide immediate feedback to developers in their IDE
- Make code reviews more focused and productive
- Simplify your codebase by ensuring consistent practices

You can learn more about architecture validation in our [online documentation](https://doc.metalama.net/conceptual/architecture/usage?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email5).

Thank you for following along! We hope you enjoyed this series. Remember, the vast majority of Metalama’s features (85% of the codebase) are free and open source. Follow our [Getting Started](https://doc.metalama.net/conceptual/getting-started?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email5) guide to start your journey against boilerplate code and architecture headaches—or join the conversation on our [GitHub discussion space](https://github.com/orgs/metalama/discussions/categories/q-a). You can also reply to this email and I’ll connect you directly with our engineering team.

All the best,  
**{{sendingAccountFirstName}}**  
Community Manager

*P.S. This was the last email in our series.*
