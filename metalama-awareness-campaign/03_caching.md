# Here is How to Save Time on Caching


Hello!

It's Fedja from Metalama again. In my previous emails, I described Metalama as a meta-programming _framework_ that allows you to generate and validate code as you type.

If you looked at our API and documentation, you may have got the impression that the framework is deep and complex.

Good news is, **you don't need to write your own aspects**. You can find open-source and professionally supported aspects on [Metalama Marketplace](https://www.postsharp.net/metalama/marketplace), including code contracts, caching, observability (INotifyPropertyChanged), WPF commands and dependency properties, and much more.

Let's look at caching today.

## Adding Caching to Your App

Metalama supports caching with and without Dependency Injection (DI). In our first example, we will explore its usage in a project that employs DI.

You can add caching to your app in just three steps:

1. Add the [Metalama.Patterns.Caching.Aspects](https://www.nuget.org/packages/Metalama.Patterns.Caching.Aspects/) package to your project.
2. Navigate to all methods that need caching and add the `[Cache]` custom attribute.


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

3. Go to the application startup code and call `AddMetalamaCaching`. This adds the `ICachingService` interface to your `IServiceCollection`, enabling the `[Cache]` aspect to be used on all objects instantiated by the DI container.

    ```c#
     builder.Services.AddMetalamaCaching();
    ```

    This will use the `MemoryCache` by default. If you want to [use Redis](https://doc.postsharp.net/metalama/preview/patterns/caching/redis), do this:

    ```c#
    builder.Services.AddMetalamaCaching( caching => caching.WithBackend( backend => backend.Redis() ) );
    ```

    Want a `MemoryCache` _in front_ of your Redis cache? No problem. The service will listen to Redis notifications to invalidate the L1 cache.

    ```c#
    builder.Services.AddMetalamaCaching(
            caching => caching.WithBackend(
                backend => backend.Redis().WithL1() ) );
    ```

## What Metalama does for you

At build time, Metalama transforms your code on-the-fly:
* It pulls the dependency to `ICachingService`.
* It generates the [cache key](https://doc.postsharp.net/metalama/preview/patterns/caching/caching-keys).
* It wraps your cached method into a delegate before calling `ICachingService.GetOrAdd`.

Other features of this open-source caching library include:

* Serialization.
* Robust [invalidation](https://doc.postsharp.net/metalama/preview/patterns/caching/invalidation). Say goodbye to the cache key hell.
* Multi-node [synchronization](https://doc.postsharp.net/metalama/preview/patterns/caching/pubsub) over Redis or Azure Service Bus.
* Transparent handling of weird types like `IEnumerable` or `Stream`.
* [Locking](https://doc.postsharp.net/metalama/preview/patterns/caching/locking).
* Compatible with .NET Aspire.

## Conclusion

Applying caching to an application can dramatically improve performance, but implementing the pattern by hand is not straightforward. Luckily, Metalama does all the heavy lifting for you while remaining flexible enough so you can customize the library to meet your specific requirements.

Caching is just one of the open-source aspects built by our team. For more, check [Metalama Marketplace](https://www.postsharp.net/metalama/marketplace).

Our development team is looking forward to your feedback and questions on our [Slack community workspace](https://www.postsharp.net/slack). Of course, you can also answer this email and I’ll make sure it will reach an engineer.

Thank you!

All the best,
Fedja
Community Manager

*P.S. We will send you 2 more emails about Metalama and then stop. You can unsubscribe at any time.*