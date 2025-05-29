---
subject: 'Here is How to Save Time on Caching'
---

Hi {{firstName}},

This is **{{sendingAccountFirstName}}** from Metalama. In my previous emails, I introduced Metalama as the open-source meta-programming framework that helps you generate code during compilation, keeping your source code clean and concise.

If you have browsed our API or documentation, you might have noticed that the framework is deep and powerful. But here is the best part: **you do not need to write your own aspects**. The [Metalama Marketplace](https://metalama.net/marketplace?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2) offers a growing collection of open-source and professionally supported aspects, including [code contracts](https://metalama.net/applications/contracts?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2), caching, [observability](https://metalama.net/applications/inotifypropertychanged?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2) (INotifyPropertyChanged), WPF [commands](https://metalama.net/applications/command?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2), [dependency properties](https://metalama.net/applications/dependency-property?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2), and more.

Today, let us focus on caching.

## Adding Caching to Your App

Metalama supports caching with or without Dependency Injection (DI). Here is how you can add caching to your application in just a few steps:

1. Add the [Metalama.Patterns.Caching.Aspects](https://www.nuget.org/packages/Metalama.Patterns.Caching.Aspects/) package to your project.
2. Add the `[Cache]` attribute to any method you want to cache.

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

3. In your application startup code, call `AddMetalamaCaching` to register the caching service:

    ```c#
    builder.Services.AddMetalamaCaching();
    ```

    By default, this uses `MemoryCache`.

## What Metalama Does for You

At build time, Metalama automatically transforms your code:

* It injects the dependency on `ICachingService`.
* It generates the [cache key](https://doc.metalama.net/patterns/caching/caching-keysy?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2).
* It wraps your cached method in a delegate and calls `ICachingService.GetOrAdd`.

Other features of this open-source caching library include:

* Serialization support
* Robust [invalidation](https://doc.metalama.net/patterns/caching/invalidationy?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2) to avoid cache key headaches
* Transparent handling of types such as `IEnumerable` or `Stream`
* [Locking](https://doc.metalama.net/patterns/caching/lockingy?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2)
* Support for Redis, hybrid, and local caches synchronized over a message bus (premium feature)
* Compatibility with .NET Aspire

If you want to cache computed properties or parameterless values, using `Metalama.Patterns.Caching.Aspects` might be more than you need. In that case, consider the [memoization](https://doc.metalama.net/patterns/memoization?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2) library, which is simpler and faster.

## Conclusion

Adding caching can dramatically improve performance, but implementing it by hand is rarely straightforward. Metalama takes care of the heavy lifting while giving you the flexibility to customize caching to your needs.

Caching is just one of the open-source aspects built by our team. Explore more on the [Metalama Marketplace](https://metalama.net/marketplace?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email2).

We would love to hear your thoughts, questions, or feedback. Join the conversation on our [GitHub discussion space](https://github.com/orgs/metalama/discussions/categories/q-a), or simply reply to this email and I will connect you directly with our engineering team.

Thank you for your time.

All the best,
**{{sendingAccountFirstName}}**
Community Manager

*P.S. We will send you three more emails about Metalama and then stop. You can unsubscribe at any time.*