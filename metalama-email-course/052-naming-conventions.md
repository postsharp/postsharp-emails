---
subject: "Validating Naming Conventions"
---


In previous emails, we demonstrated how Metalama can generate boilerplate code on-the-fly during compilation, automating the implementation of repetitive but necessary code. However, code generation is just one of Metalama's capabilities. In this email, we will explore Metalama's second pillar: its ability to validate source code against architectural rules, starting with naming conventions.

{: .note }
Architecture validation is available only with Metalama Professional and is not included in the open-source version. Our next email will return to open-source features and use cases.

## Why Care About Naming Conventions?

Adhering to naming conventions keeps code clean and understandable, whether you're working in a team or independently. It's like maintaining a tidy room: it helps everyone, including your future self, quickly find what they need without confusion.

While your IDE can enforce basic naming conventions like casing or prefixes, and `.editorconfig` can configure code style, there is no standard tool to verify the meaning of names themselves. For example, aside from special cases like collections or dictionaries, naming conventions often require custom validation.

Well-named types and methods can communicate their purpose and functionality clearly. A common rule is that types should have a suffix indicating their role.

## Enforcing Naming Conventions Using a Custom Attribute

Metalama makes it easy to enforce naming conventions in your codebase—in real time, directly within the IDE.

To enforce naming conventions, we will use the `Metalama.Extensions.Architecture` package. Make sure to add it to your project first.

For this example, suppose we have a base class `Entity` that all entity classes must derive from. The team decides that all entity classes must have the `Entity` suffix in their names.

To enforce this convention, simply add the `[DerivedTypesMustRespectNamingConvention]` attribute to the `Entity` class:

```c#
using Metalama.Extensions.Architecture.Aspects;

[DerivedTypesMustRespectNamingConvention("*Entity")]
public abstract class Entity
{
    public string Id { get; }
    public abstract string Description { get; }

    protected Entity(string id)
    {
        Id = id;
    }
}
```

From this point on, a warning will be issued for any class derived from `Entity` that does not follow the naming convention.

For example, consider the following code:

```c#
public class Customer : Entity
{
    public Customer(string id, string name) : base(id)
    {
        this.Name = name;
    }

    public string Name { get; }

    public override string Description => this.Name;
}
```

Since the `Customer` class does not follow the naming convention, a warning is immediately displayed.

![](images/attribute-namingconvention.png)

## Enforcing Naming Conventions with a Fabric

What if you don't own the source code of the base class or interface for which you want to enforce a naming convention? What if the type comes from a library?

For instance, imagine an application that heavily uses stream readers, with several classes created by different team members to implement these readers for various tasks. The team decides that all such classes must have the `StreamReader` suffix for clarity.

Fabrics are an excellent tool for enforcing naming conventions on types you don't own. Fabrics are compile-time classes executed within the compiler or IDE. Fabrics derived from `ProjectFabric` apply to an entire project.

Here's how to create a fabric to enforce this naming convention:

```c#
using Metalama.Extensions.Architecture.Fabrics;
using Metalama.Framework.Fabrics;

internal class NamingConvention : ProjectFabric
{
    public override void AmendProject(IProjectAmender amender)
    {
        amender
            .SelectTypesDerivedFrom(typeof(StreamReader))
            .MustRespectNamingConvention("*Reader");
    }
}
```

In the code above, the fabric examines each class in the project derived from `StreamReader`. If any such class does not have a name ending in `Reader`, a warning is displayed.

With this custom validation rule in place, let's test it. In the code below, we have two classes derived from `StreamReader`. One follows the naming convention, while the other does not, triggering a warning.

```c#
internal class FancyStream : StreamReader
{
    public FancyStream(Stream stream) : base(stream)
    {
    }
}

internal class SuperFancyStreamReader : StreamReader
{
    public SuperFancyStreamReader(Stream stream) : base(stream)
    {
    }
}
```

The warning is displayed as shown below:

![](images/naming-conventions-1.gif)

## Summary

Although these examples are simple, they demonstrate how Metalama can help validate your codebase and enforce architectural rules. For more information, refer to the [Metalama Documentation](https://doc.metalama.net/conceptual/architecture/naming-conventions).
