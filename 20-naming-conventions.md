# Common Tasks: Validating Code (Naming Conventions)

In my previous email, I showed how Metalama can generate the boilerplate code for you on-the-fly during compilation, automatinc the chore of implementing necessary but repetitive code. Code generation is not the only thing Metalama can do. In this email, I will look into Metalama's second pillar: its ability to validate source code against architectural rules. Let's start with naming conventions.

Respecting naming conventions keeps code clean and understandable, whether you're working in a team or flying solo. It's like keeping a tidy room; it helps everyone, including your future self, to quickly find what they need without getting lost. 

You probably know that your IDE can already enforce the most basic naming conventions like casing or prefixes. Nowadays, this is done through `.editorconfig`. However, except for special classes like collections or dictionaries, there is no standard tool to verify the name itself.

Properly named types and methods can often convey their essence and purpose just from their name. A common rule is that types must have a suffix that say what they are.

For instance, imagine a situation where an application makes extensive use of stream readers, and there are several classes created by different team members that implement these readers to perform various tasks. A decision has been made to ensure that all such classes have the suffix `StreamReader` added to their names for clarity.

Fabrics, particularly `ProjectFabric`, are an excellent way to enforce this type of validation as they can cover an entire project.

Let's create a Fabric that checks the codebase to ensure that developers are adhering to the naming convention.

```c#
using Metalama.Extensions.Architecture.Fabrics;
using Metalama.Framework.Fabrics;

internal class NamingConvention : ProjectFabric
{
    public override void AmendProject(IProjectAmender amender)
    { 
        amender.Verify().SelectTypesDerivedFrom(typeof(StreamReader)).MustRespectNamingConvention("*Reader"); 
    }
}
```

In the code above, the fabric examines each class in the project that is derived from `StreamReader`. If the name of any class that matches this criterion does not end in `Reader`, a warning is displayed.

With our custom validation rule written, let's put it to the test. In the code below, we have two classes derived from StreamReader. One has the 'Reader' suffix, the other does not and, as such, it should trigger a warning.

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

This is a very simple example, but it illustrates how Metalama can be used to help validate your codebase and enforce rules. More information about this can be found in the [Metalama Documentation](https://doc.postsharp.net/metalama/conceptual/architecture/naming-conventions).
