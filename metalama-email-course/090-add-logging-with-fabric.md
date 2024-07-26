# Using Metalama: Project Fabrics

In previous discussions, we utilized a custom attribute to add aspects to a target class or method. We identified individual methods requiring logging and added the `[Log]` custom attribute.

In a real-world application, you may encounter dozens of classes and hundreds of methods. To achieve comprehensive logging of the application, you would need to sift through each class individually, adding the `[Log]` attribute to each method. Although this process is significantly more efficient than incorporating the necessary logging code into each method, it remains a substantial task to manually traverse each class and add the attribute to each method.

Fortunately, Metalama provides a mechanism to automate this process, referred to as _fabrics_.

In the project, incorporate an additional class. The name is irrelevant, but it must inherit from `ProjectFabric`.

```c#
using Metalama.Framework.Fabrics;

namespace UsingMetalama.Fabrics
{
    internal class LogDistribution : ProjectFabric
    {
        public override void AmendProject(IProjectAmender amender)
        {
            throw new NotImplementedException();
        }
    }
}
```

From this rudimentary implementation, it's evident that this class will modify the current project. Now, let's enhance this so that it performs an actual function.

```c#
using Metalama.Framework.Fabrics;

namespace UsingMetalama.Fabrics
{
    internal class LogDistribution : ProjectFabric
    {
        public override void AmendProject(IProjectAmender amender)
        {
            amender.Outbound
                .SelectMany(t => t.AllTypes)
                .SelectMany(t => t.Methods)
                .AddAspectIfEligible<LogAttribute>();
        }
    }
}
```

In simple terms, the code we incorporated selects every class in the project, then selects each method in each class. If feasible, it appends the Log attribute to that method.

Utilizing the Metalama Tools Extension for Visual Studio, we can observe how this simple ProjectFabric has effectively manipulated our code.

![](images/fabric2.jpg)

Although this is a simplistic example, it should articulate the potency of Metalama and its potential as a time-saving tool.

We have just scratched the surface of what is achievable with Fabrics. We could apply the log attribute to all methods across a solution of projects with the assistance of a TransitiveFabric.

If we desired to target a Type or a Namespace, we could accomplish it with either TypeFabric or NamespaceFabric.

Fabrics are not only beneficial for appending aspects to your code, but they can also be utilized to implement architectural rules in your codebase.

You can read more about Fabrics [here](https://doc.postsharp.net/metalama/conceptual/using/fabrics). It's one of Metalama's more advanced features, but understanding how it operates will enable you to perform tasks that might have previously seemed nearly unachievable.

