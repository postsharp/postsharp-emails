---
subject: The Simplest Way to Cache a Method's Return Value
---

Caching is a technique used to optimize application performance by storing data that changes infrequently or is expensive to retrieve in an intermediate layer.

Implementing caching can be challenging, as it requires several components to work together seamlessly. Metalama simplifies this process significantly.

## Adding Caching to Your App

Metalama supports caching with and without Dependency Injection (DI). In our first example, we will explore its usage in a project that employs DI.

You can add caching to your app in just three steps:

1. Add the [Metalama.Patterns.Caching.Aspects](https://www.nuget.org/packages/Metalama.Patterns.Caching.Aspects/) package to your project.
2. Navigate to all methods that need caching and add the `[Cache]` custom attribute.
3. Go to the application startup code and call `AddCaching`, which adds the `ICachingService` interface to your `IServiceCollection`, enabling the `[Cache]` aspect to be used on all objects instantiated by the DI container. This code is fairly standard and omitted here for brevity, but you can find it in the [documentation](https://doc.metalama.net/patterns/caching/getting-started).

Let's examine what the `[Cache]` attribute does to your code. Consider the following example:

```c#
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
```

At build time, Metalama transforms it into the following:

```c#
public sealed class CloudCalculator
{
    [Cache]
    public int Add(int a, int b)
    {
        static object? Invoke(object? instance, object?[] args)
        {
            return ((CloudCalculator)instance).Add_Source((int)args[0], (int)args[1]);
        }

        return this._cachingService!.GetFromCacheOrExecute<int>(
            CloudCalculator._cacheRegistration_Add!, this, new object[] { a, b }, Invoke);
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
        // Skipped for brevity.
    }

    public CloudCalculator(ICachingService? cachingService = default)
    {
        this._cachingService = cachingService 
            ?? throw new System.ArgumentNullException(nameof(cachingService));
    }
}
```

As you can see, Metalama moves the original method implementation of `Add` into `Add_Source` (we would typically name it `AddCore` if the code were hand-written) and replaces `Add` with a call to the caching service.

Our potentially expensive operation is invoked using the following code:

```c#
public void Execute()
{
    for (var i = 0; i < 5; i++)
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

From the transformed code, it is evident that Metalama has automatically incorporated the `ICachingService` interface into the `CloudCalculator`. The output shows that the `CloudCalculator` was executed once, its result was cached, and the cached result was used on subsequent calls.

Without a doubt, Metalama significantly simplifies the process of implementing caching.

## Without Dependency Injection

Not every project requires or warrants the use of Dependency Injection, and it cannot be used for caching static methods. However, Metalama Caching can be used without DI.

This can be achieved by adding a small configuration file to your project:

```c#
using Metalama.Patterns.Caching.Aspects;

// Disable dependency injection.
[assembly: CachingConfiguration(UseDependencyInjection = false)]
```

The Metalama [documentation](https://doc.metalama.net/patterns/caching/getting-started) illustrates the same example as above, but without using Dependency Injection. As before, caching can be added via a single `[Cache]` attribute, and it will produce the same result.

## Configuring Caching

Metalama not only simplifies the implementation of caching but also provides ways to customize your cache keys and exclude certain parameters.

Here are a few topics to explore:

- [Customizing caching keys](https://doc.metalama.net/patterns/caching/caching-keys)
- [Excluding parameters](https://doc.metalama.net/patterns/caching/exclude-parameters)
- [Configuring expiration, priority, or auto-reload](https://doc.metalama.net/patterns/caching/configuring)

## Invalidating the Cache

As Phil Karlton once [famously said](https://www.karlton.org/2017/12/naming-things-hard/), "There are only two hard things in Computer Science: cache invalidation and naming things."

Metalama Caching offers two approaches to cache invalidation:

- **Explicit** cache invalidation by using the `[InvalidateCache]` custom attribute or the `ICachingService.Invalidate` method. Both approaches are type-safe, but they have drawbacks: the _Update_ methods must know which _Read_ methods they must invalidate, and this must be kept in sync.
- **Implicit** cache invalidation through **cache dependencies**, where Metalama builds a dependency graph. This approach provides better separation of concerns between the _Update_ and _Read_ layers but comes at the cost of higher performance and memory overhead due to the need to maintain this graph.

For details, see [Invalidating the cache](https://doc.metalama.net/patterns/caching/invalidation) in the documentation.

## Distributed Caching

If you have a distributed application that could benefit from caching, Metalama has you covered with three possible topologies:

- Server or cloud caching with [Redis](https://doc.metalama.net/patterns/caching/redis).
- Hybrid caching, where an in-memory cache stands in front of a Redis cache.
- Several local in-memory caches (typically on different nodes of your app) synchronized over [Azure Service Bus](https://doc.metalama.net/patterns/caching/pubsub).

Azure and Redis adapters for Metalama Caching require a Metalama Professional license.

## Conclusion

Applying caching to an application can dramatically improve performance, but implementing the pattern is not straightforward. Metalama does all the heavy lifting for you and provides several flexible implementations that you can customize to meet your specific requirements.

By leveraging Metalama Caching, you'll find that implementing caching is both simpler and more efficient than creating a bespoke solution. Metalama Caching is completely configurable and extensible and comes with proprietary but source-available extensions for Azure and Redis.
