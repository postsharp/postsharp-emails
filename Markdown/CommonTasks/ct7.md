# Common Tasks: Caching

Caching is way to optimise the performance of an application which involves storing data, that either changes infrequently or is expensive to retrieve, in an intermediate layer.

It is not the easiest design pattern to implement requiring as it does a number of component parts to work together seamlessly. Using the [Metalama.Patterns.Caching.Aspects](https://www.nuget.org/packages/Metalama.Patterns.Caching.Aspects/) library on the other hand makes implementing it much easier.

Metalama supports caching with and without Dependency Injection and in our first example we'll look at using it in a project that is using DI.

You should begin (after having added the relevant Metalama Nuget Package to your application) by ensuring that you include a call to the `AddCaching` extension method provided by Metalama that adds the required instance of the ICachingService interface. That will ensure that the `[Cache]` aspect can be used on all objects that are themselves instantiated by the DI container.

This means that Metalama would transform a potentially expensive operation like this;

```c#
using Metalama.Patterns.Caching.Aspects;

namespace CreatingAspects.Caching
{
    public sealed class CloudCalculator
    {

        [Cache]
        public int Add(int a, int b)
        {
            Console.WriteLine("Doing some very hard work.");

            this.OperationCount++;

            Console.WriteLine("Finished doing some very hard work.");

            return a + b;
        }

        public int OperationCount { get; private set; }
    }
}
```

to this;

```c#
using System.Reflection;
using Metalama.Patterns.Caching;
using Metalama.Patterns.Caching.Aspects;
using Metalama.Patterns.Caching.Aspects.Helpers;

namespace CreatingAspects.Caching
{
    public sealed class CloudCalculator
    {

        [Cache]
        public int Add(int a, int b)
        {
            static object? Invoke(object? instance, object?[] args)
            {
                return ((CloudCalculator)instance).Add_Source((int)args[0], (int)args[1]);
            }

            return this._cachingService!.GetFromCacheOrExecute<int>(CloudCalculator._cacheRegistration_Add!, this, new object[] { a, b }, Invoke);
        }

        private int Add_Source(int a, int b)
        {
            Console.WriteLine("Doing some very hard work.");

            this.OperationCount++;

            Console.WriteLine("Finished doing some very hard work.");

            return a + b;
        }

        public int OperationCount { get; private set; }


        private static readonly CachedMethodMetadata _cacheRegistration_Add;

        private ICachingService _cachingService;

        static CloudCalculator
        ()
        {
            CloudCalculator._cacheRegistration_Add = CachedMethodMetadata.Register(RunTimeHelpers.ThrowIfMissing(typeof(CloudCalculator).GetMethod("Add", BindingFlags.Public | BindingFlags.Instance, null, new[] { typeof(int), typeof(int) }, null)!, "CloudCalculator.Add(int, int)"), new CachedMethodConfiguration() { AbsoluteExpiration = null, AutoReload = null, IgnoreThisParameter = null, Priority = null, ProfileName = (string?)null, SlidingExpiration = null }, false);

        }

        public CloudCalculator
        (ICachingService? cachingService = default)
        {
            this._cachingService = cachingService ?? throw new System.ArgumentNullException(nameof(cachingService));

        }
    }
}
```

For the sake of brevity most of the application setup code has been omitted but can be seen in the [documentation](https://doc.postsharp.net/metalama/patterns/caching/getting-started). Our potentially expensive operation is called via the following code;

```c#
public void Execute()
{
    for(var i = 0; i < 5; i++)
    {
        var value = this._cloudCalculator.Add(1, 1);
        Console.WriteLine($"CloudCalculator returned {value}.");
    }

    Console.WriteLine(
        $"In total, CloudCalculator performed {this._cloudCalculator.OperationCount} operation(s).");
}
```

and when run it produces the following output.

```
Doing some very hard work.
Finished doing some very hard work.
CloudCalculator returned 2.
CloudCalculator returned 2.
CloudCalculator returned 2.
CloudCalculator returned 2.
CloudCalculator returned 2.
In total, CloudCalculator performed 1 operation(s).
```

You can see from the transformed code that Metalama has automatically pulled the ICachingService interface into the CloudCalculator. You can also see from the resulting application output That the CloudCalculator was run once and its output result was then cached and that cached result used on the subsequent occasions that it was called.

Without doubt Metalama has made the process of cache implementation much simpler.

Not every project warrants or requires the use of Dependency Injection and in any event it couldn't be used for the purposes of caching static methods. Fortunately Metalama Caching can be used without DI.

Doing so is as simple as adding a small configuration file to your project.

```c#
using Metalama.Patterns.Caching.Aspects;

// Disable dependency injection.
[assembly: CachingConfiguration( UseDependencyInjection = false )]
```

The Metalama [documentation](https://doc.postsharp.net/metalama/patterns/caching/getting-started) illustrates the example we've just used but without using Dependency injection. As before Caching can be added via a single `[Cache]` attribute and it will produce the same result.

Metalama not only makes implementing caching a breeze but it provides the means to customise your cache keys, exclude certain parameters and even invalidate a particular cache all by doing no more than adding an attribute. That principle is even extended to configuring the caching itself via the `[CachingConfiguration()]` attribute.

Applying caching to an application can improve performance dramatically however implementing the pattern is not easy. Metalama does all of the hard work for you and provides a number of flexible implementations which you could of course customise to meet any specific requirements that you might have.

If you have a distributed application that you feel would benefit from caching then Metalama has that [covered for you](https://doc.postsharp.net/metalama/patterns/caching/redis).

Metalama also supports the synchronisation of [local in-memory caches for multiple servers](https://doc.postsharp.net/metalama/patterns/caching/pubsub), offering support for both the Azure service bus and Redis Pub/Sub.

By leveraging Metalama you'll find that implementing caching is both simpler and more efficient than trying to create a bespoke solution for yourself.

<br>

If you'd like to know more about Metalama in general, visit our [website](https://www.postsharp.net/metalama).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
