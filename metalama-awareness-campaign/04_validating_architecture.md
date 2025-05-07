# Get your development team to adhere to architecture

Developers need to follow specific rules and conventions to work together effectively as a team. This adherence ensures that individual contributions integrate seamlessly into the overall application.

In a previous email, we discussed how to enforce naming conventions. Today, let's examine how to verify that components are _used_ as expected. You might have just written a method meant only to support a test, but how can you enforce that it's not used in production code?

* Option 1: Add comments such as **DO NOT USE IN PRODUCTION CODE!**, hoping the exclamation mark will help.
* Option 2: Rely on code reviews. This can be slow, frustrating, and costly.
* Option 3: Make your architecture _executable_ so it can be automatically enforced straight from the editor. You guessed it, that's where Metalama comes in handy.

The [open-source](https://github.com/postsharp/Metalama.Extensions/tree/HEAD/src/Metalama.Extensions.Architecture) [Metalama.Extensions.Architecture](https://www.nuget.org/packages/Metalama.Extensions.Architecture) package offers several pre-made custom attributes and compile-time APIs that cover many common conventions teams might want to follow.

## Custom attributes

Let's assume we have a constructor that slightly modifies the object's behavior to make it more testable. We want to ensure that this constructor is used only in tests. Metalama provides the [CanOnlyBeUsedFrom](https://doc.postsharp.net/etalama/api/metalama-extensions-architecture-aspects-canonlybeusedfromattribute) attribute for this purpose.

```c#
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

If we attempt to create a new `OrderShipping` instance in a namespace that isn't suffixed by `Tests`, we will see a warning.

![](../metalama-email-course/images/ValidationWarning.jpg)

## Fabrics

Suppose we have a project composed of a large number of components. Each of these components is implemented in its own namespace and is made up of several classes. There are so many components that we don't want to have them each in their own project.

However, we still want to isolate components from each other. Specifically, we want `internal` members of each namespace to be visible only within this namespace. Only `public` members should be accessible outside of its home namespace.

Additionally, we want `internal` components to be accessible from any test namespace.

With Metalama, you can validate each namespace by adding a _fabric_ type: a compile-time class that executes within the compiler or the IDE.

```cs
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

Now, if some foreign code tries to access an internal API of the `MyComponent` namespace, a warning will be reported.

In addition to `InternalsCanOnlyBeUsedFrom`, the package also includes `InternalsCannotBeUsedFrom`, `CanOnlyBeUsedFrom`, and `CannotOnlyBeUsedFrom`. You can easily build more rules based on the code model.

## Conclusion

We've just seen two examples of how you can validate your code using pre-built Metalama aspects or compile-time APIs.

Enforcing rules and conventions in this manner allows you to:

- Eliminate the need for a written set of rules to which everyone must refer.
- Provide immediate feedback to developers within the familiar confines of the IDE itself.
- Improve code reviews as they now only need to focus on the code itself.
- Simplify the codebase because it adheres to consistent rules.

You can learn more about architecture validation in our online [documentation](https://doc.metalama.net/conceptual/architecture/usage).
