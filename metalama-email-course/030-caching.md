# The Simplest Way to Cache a Method's Return Value

Caching is a technique to optimize the performance of an application by storing data that either changes infrequently or is expensive to retrieve, in an intermediate layer.

Implementing caching can be challenging as it requires several components to work together seamlessly. Metalama simplifies this process significantly.

## Adding Caching to Your App

Metalama supports caching with and without Dependency Injection (DI). In our first example, we will explore its usage in a project that employs DI.

You can add caching to your app in just three steps:

1. Add the [Metalama.Patterns.Caching.Aspects](https://www.nuget.org/packages/Metalama.Patterns.Caching.Aspects/) package to your project.
2. Navigate to all methods that need caching and add the `[Cache]` custom attribute.
3. Go to the application startup code and call `AddCaching`, which adds the `ICachingService` interface to your `IServiceCollection`, enabling the `[Cache]` aspect to be used on all objects instantiated by the DI container. This code is rather standard and we omit it for brevity, but you can find it in the [documentation](https://doc.postsharp.net/metalama/patterns/caching/getting-started).

Let's examine what the `[Cache]` attribute does with your code. Consider the following example:

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

At build time, Metalama transforms it into the following:

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

        static CloudCalculator()
        {
            CloudCalculator._cacheRegistration_Add = CachedMethodMetadata.Register(RunTimeHelpers.ThrowIfMissing(typeof(CloudCalculator).GetMethod("Add", BindingFlags.Public | BindingFlags.Instance, null, new[] { typeof(int), typeof(int) }, null)!, "CloudCalculator.Add(int, int)"), new CachedMethodConfiguration() { AbsoluteExpiration = null, AutoReload = null, IgnoreThisParameter = null, Priority = null, ProfileName = (string?)null, SlidingExpiration = null }, false);
        }

        public CloudCalculator(ICachingService? cachingService = default)
        {
            this._cachingService = cachingService ?? throw new System.ArgumentNullException(nameof(cachingService));

        }
    }
}
```

As you can see, Metalama moved the original method implementation of `Add` into `Add_Source` (we would typically name it `AddCore` if the code were hand-written), and replaced `Add` with a call to the caching service.

Our potentially expensive operation is invoked using the following code:

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

When executed, it produces the following output:

```text
Doing some very hard work.
Finished doing some very hard work.
CloudCalculator returned 2.
CloudCalculator returned 2.
CloudCalculator returned 2.
CloudCalculator returned 2.
CloudCalculator returned 2.
In total, CloudCalculator performed 1 operation(s).
```

From the transformed code, it is evident that Metalama has automatically incorporated the ICachingService interface into the CloudCalculator. The output shows that the CloudCalculator was executed once, its output result was cached, and the cached result was used on subsequent calls.

Without a doubt, Metalama significantly simplifies the process of cache implementation.

## Without Dependency Injection

Not every project requires or warrants the use of Dependency Injection, and it cannot be used for caching static methods. However, Metalama Caching can be used without DI.

This can be achieved by adding a small configuration file to your project:

```c#
using Metalama.Patterns.Caching.Aspects;

// Disable dependency injection.
[assembly: CachingConfiguration( UseDependencyInjection = false )]
```

The Metalama [documentation](https://doc.postsharp.net/metalama/patterns/caching/getting-started) illustrates the same example as above, but without using Dependency Injection. As before, caching can be added via a single `[Cache]` attribute and it will produce the same result.

## Going Further with Caching

Metalama not only simplifies the implementation of caching but also provides means to customize your cache keys, exclude certain parameters, and invalidate a particular cache by merely adding an attribute. This principle even extends to configuring the caching itself via the `[CachingConfiguration()]` attribute.

Applying caching to an application can dramatically improve performance, but implementing the pattern is not straightforward. Metalama does all the heavy lifting for you and provides several flexible implementations that you can customize to meet your specific requirements.

If you have a distributed application that could benefit from caching, Metalama has that [covered for you](https://doc.postsharp.net/metalama/patterns/caching/redis).

Metalama also supports the synchronization of [local in-memory caches for multiple servers](https://doc.postsharp.net/metalama/patterns/caching/pubsub), offering support for both the Azure service bus and Redis Pub/Sub.

By leveraging Metalama, you'll find that implementing caching is both simpler and more efficient than creating a bespoke solution.
