---
subject: 'Classic Design Patterns Without Boilerplate: Builder, Proxy, and More with Metalama'
---

Hi {{firstName}},

This is **{{sendingAccountFirstName}}** from Metalama, the open-source meta-programming framework for .NET. In my previous emails, I showed how Metalama can help you eliminate boilerplate in DevOps and UI scenarios. Today, I’d like to show you how Metalama can simplify classic design patterns. You’ve already seen the Memento pattern. Let’s look at a few more: Builder, Decorator, and Proxy.

## Builder Pattern

The [Builder pattern](https://metalama.net/applications/builder?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4) is a creational design pattern that lets you construct complex objects step by step. It’s especially useful for creating immutable objects with many optional parameters or properties. The Abstract Builder variant adds even more flexibility.

The main drawback of the Builder pattern is the sheer amount of repetitive code it requires. With Metalama, you can eliminate almost all of this boilerplate.

Consider a simple immutable class:

```csharp
[GenerateBuilder]
public partial class Song
{
    [Required] public string Artist { get; }
    [Required] public string Title { get; }
    public TimeSpan? Duration { get; }
    public string Genre { get; } = "General";
}
```

The [GenerateBuilder](https://doc.metalama.net/examples/builder?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4) aspect generates a nested Builder class and a `ToBuilder` method for you:

```csharp
public partial class Song
{

  public Builder ToBuilder() => new Builder(this);

  public class Builder
  {
    public Builder(string artist, string title)
    {
      Artist = artist;
      Title = title;
    }

    internal Builder(Song source)
    {
      Artist = source.Artist;
      Title = source.Title;
      Duration = source.Duration;
      Genre = source.Genre;
    }

    public string Artist { get; set; }
    public TimeSpan? Duration { get; set; }
    public string Genre { get; set; } = "General";
    public string Title { get; set; }

    public Song Build()
    {
      var instance = new Song(Artist, Title, Duration, Genre)!;
      return instance;
    }
  }
}
```

That’s a lot of code you don’t have to write or maintain!

For more details, check out these resources:

- Blog post: [Implementing the Builder pattern with Metalama](https://metalama.net/blog/builder-pattern-with-metalama?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4)
- Example: [Implementing the Builder pattern without boilerplate](https://doc.metalama.net/examples/builder?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4)

## Proxy & Interceptor Patterns

The [Proxy pattern](https://metalama.net/applications/proxy?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4) is a structural design pattern that lets you provide a substitute or placeholder for another object, typically to add new behavior. In C#, proxies are usually based on interfaces.

You can implement the proxy’s added behavior in each member, or abstract it into an _Interceptor_.

Implementing the Proxy pattern by hand means duplicating all interface members—a lot of boilerplate. With Metalama, you can generate the entire proxy automatically. Use `ProjectFabric` as a compile-time entry point to tell Metalama what to generate or validate:

```csharp
// This class executes at compile time!
public class Fabric : ProjectFabric
{
    public override void AmendProject(IProjectAmender amender)
    {
        amender.SelectReflectionType(typeof(IOrderService)).GenerateStaticProxy();
    }
}
```

This generates an `OrderServiceProxy` class, which you can use like this:

```csharp
var orderServiceProxy = new OrderServiceProxy(
    new OrderService(),
    new LoggingInterceptor());

orderServiceProxy.PlaceOrder(order);
```

You can find the full example on [GitHub](https://github.com/metalama/Metalama.Samples/tree/HEAD/examples/Metalama.Samples.Proxy).

## Deep Cloning

Another common pattern is [deep cloning](https://doc.metalama.net/examples/clone/clone-1?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4). Unlike shallow cloning (which just calls `MemberwiseClone`), deep cloning requires recursively cloning child objects—a task that’s tedious and error-prone to do by hand.

.NET doesn’t have a built-in concept of “child” objects, so a common solution is to mark child properties and fields with a `[Child]` attribute. Here’s how it looks:

```csharp
[Cloneable]
internal class Game
{
    public Player Player { get; set; }

    [Child]
    public GameSettings Settings { get; set; }
}
```

Metalama generates the following code at compile time:

```csharp
[Cloneable]
internal class Game : ICloneable
{
    public Player Player { get; set; }

    [Child]
    public GameSettings Settings { get; set; }

    public virtual Game Clone()
    {
        var clone = (Game)this.MemberwiseClone();
        clone.Settings = ((GameSettings)this.Settings.Clone());
        return clone;
    }

    object ICloneable.Clone()
    {
        return Clone();
    }
}
```

See the [documentation](https://doc.metalama.net/examples/clone?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4) for more details.

## Why Not Just Use Roslyn Source Generators?

You might wonder: couldn’t all this be done with plain Roslyn source generators? For simple cases, yes. But Metalama is much more powerful and easier to use.

Metalama is a high-level framework built on top of Roslyn generators. In fact, Metalama uses Roslyn generators for its design-time experience. But with Metalama, you get:

- T#, a C#-to-C# template language
- Aspect composition: apply multiple aspects to the same class and control their order
- The ability to override almost anything—not just add partial classes
- Built-in error and warning reporting (Roslyn generators require a separate analyzer for this)

To learn more about code generation alternatives, read [this article](https://metalama.net/alternatives/code-generation?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4).

## Other Patterns

We can’t cover every use case in a single email, but here are more ways Metalama can help:

- **Design Patterns:** [Singleton](https://metalama.net/applications/classic-singleton?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Memento](https://metalama.net/applications/memento?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Factory](https://metalama.net/applications/factory?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Builder](https://metalama.net/applications/builder?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Decorator](https://metalama.net/applications/decorator?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Proxy](https://metalama.net/applications/proxy?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), ...
- **UI Patterns:** [INotifyPropertyChanged](https://metalama.net/applications/inotifypropertychanged?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Change Tracking](https://metalama.net/applications/command?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Memoization](https://metalama.net/applications/memoization?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Undo/Redo](https://metalama.net/applications/undo-redo?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Command](https://metalama.net/applications/command?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Dependency Properties](https://metalama.net/applications/dependency-property?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Enum View-Mode](https://doc.metalama.net/examples/enum-viewmodel?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4) ...
- **Object Services:** [Cloning](https://doc.metalama.net/examples/clone?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [ToString](https://doc.metalama.net/examples/tostring?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), Comparison, ...
- **Defensive Programming:** [Code Contracts](https://metalama.net/applications/contracts?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4) (preconditions, post-conditions, invariants)
- **DevOps:** [Logging & Tracing](https://metalama.net/applications/logging?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Metrics](https://metalama.net/applications/metrics?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Caching](https://metalama.net/applications/caching?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4), [Exception Handling](https://metalama.net/applications/exception-handling?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4)

For even more use cases and open-source aspect implementations, visit the [Metalama Marketplace](https://metalama.net/marketplace?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email4).

## Conclusion

Classic design patterns remain essential in modern .NET applications, but many still require a lot of boilerplate code. Metalama helps you generate this code automatically, so you can focus on what matters most: building great software.

We’d love to hear your thoughts, questions, or feedback. Join the conversation on our [GitHub discussion space](https://github.com/orgs/metalama/discussions/categories/q-a), or simply reply to this email and I’ll connect you directly with our engineering team.

Thank you for your time.

All the best,  
**{{sendingAccountFirstName}}**  
Community Manager

*P.S. We will send you two one email about Metalama and then stop. You can unsubscribe at any time.*