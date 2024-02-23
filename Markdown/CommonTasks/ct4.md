# Common Tasks: Validating Code (Naming Conventions)

One of the most difficult things to validate particularly for large teams but it can be equally applicable to smaller teams or even individuals working on an a large codebase are Naming conventions.

Properly named methods can frequently convey intent or purpose just from their name so having rules in place to enforce this is not uncommon. The issue tends to be with how those rules are then enforced.-

By way of an example imagine a situation where an application makes extensive use of stream readers and there are several classes created by different members of the team that implement said readers to perform various tasks. A decision has been taken to ensure that all such classes have the suffix 'StreamReader' added to their names so that it is clear what they do.

Fabrics are a great way to enforce this type of validation, particularly ProjectFabric as they can cover an entire project.

We'll create a Fabric that checks the codebase to ensure that the naming convention is being adhered to by the developers.

<br>

```c#
using Metalama.Extensions.Architecture.Fabrics;
using Metalama.Framework.Fabrics;


    internal class NamingConvention : ProjectFabric
    {


        public override void AmendProject(IProjectAmender amender)
        { amender.Verify().SelectTypesDerivedFrom(typeof(StreamReader)).MustRespectNamingConvention("*Reader"); }


    }
```

<br>

In the code above the fabric looks at each class in the project that is derived from `StreamReader`. If the name of any class that matches that criteria does not end in'Reader' then a warning is displayed.

With our custom validation rule written let's put it to the test. In the code below we have two classes derived from StreamReader. One has the reader suffix the other does not and as such it should cause a warning to be displayed.

<br>

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

<br>

We can see our warning in action below.

<br>

![](images/ct3.gif)

<br>

This is clearly a very simple example but it does illustrate how Metalama can be used to help validate your codebase and enforce rules. More information about this can be found in the [Metalama Documentation](https://doc.postsharp.net/metalama/conceptual/architecture/naming-conventions).

<br>

If you'd like to know more about Metalama in general then visit our [website](https://www.postsharp.net/metalama).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
