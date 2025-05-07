# Validating Naming Conventions

In my previous emails, I demonstrated how Metalama can generate boilerplate code on-the-fly during compilation, automating the task of implementing necessary but repetitive code. However, code generation is not the only functionality Metalama offers. In this email, I will explore Metalama's second pillar: its ability to validate source code against architectural rules, starting with naming conventions.



## Why Care About Naming Conventions?

Adhering to naming conventions keeps code clean and understandable, whether you're working in a team or independently. It's akin to maintaining a tidy room; it assists everyone, including your future self, in quickly locating what they need without confusion.

You're likely aware that your IDE can already enforce the most basic naming conventions like casing or prefixes. Nowadays, code style can be configured through `.editorconfig`. However, aside from special classes like collections or dictionaries, there is no standard tool to verify the name itself.

Appropriately named types and methods can often communicate their essence and purpose solely through their name. A common rule is that types must have a suffix that indicates what they are.

## Enforcing Naming Conventions Using a Custom Attribute

Metalama makes it easy to enforce naming conventions in your codebase -- in real time, straight from the IDE.

To enforce naming conventions, we will use an open-source extension of Metalama, the `Metalama.Extensions.Architecture` package. Ensure to add it to your project first.

For this first example, suppose we have a base class `Entity` that all entity classes must derive from. The team decides that all entity classes must have the `Entity` suffix in their names.

To enforce this convention, simply add the `[DerivedTypesMustRespectNamingConvention]` custom attribute to the `Entity` class.

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

From this moment on, you will receive a warning for every class derived from the `Entity` class that does not respect the naming convention.

For instance, consider the following code:

```cs
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

Since the `Customer` class does not respect the naming convention, a warning is immediately reported.

![](images/attribute-namingconvention.png)

## Enforcing Naming Conventions with a Fabric

What if we don't own the source of the base class or interface for which we want to enforce a naming convention? What if the type comes from a class library?

For instance, consider a situation where an application heavily utilizes stream readers, and there are several classes created by different team members that implement these readers for various tasks. A decision is made to ensure that all such classes have the suffix `StreamReader` added to their names for clarity.

Fabrics are an excellent tool to enforce naming conventions for types you don't own. Fabrics are compile-time classes that are executed within the compiler or IDE. Fabrics derived from `ProjectFabric` will cover an entire project.

Let's create a fabric that checks the codebase to ensure that developers are adhering to the naming convention.

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

In the code above, the fabric examines each class in the project that is derived from `StreamReader`. If the name of any class that matches this criterion does not end in `Reader`, a warning is displayed.

With our custom validation rule written, let's put it to the test. In the code below, we have two classes derived from StreamReader. One has the 'Reader' suffix, the other does not, and as such, it should trigger a warning.

```c#
namespace CommonTasks.NamingConventions
{
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
}
```

We can see our warning in action below.

![](images/naming-conventions-1.gif)

## Summary

Although both examples were quite simple, they illustrate how Metalama can be used to help validate your codebase and enforce rules. More information about this topic can be found in the [Metalama Documentation](https://doc.metalama.net/conceptual/architecture/naming-conventions).
