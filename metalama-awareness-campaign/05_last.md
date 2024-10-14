Hi,

This is the final email in our series introducing you to Metalama.

Today, let's look into more advanced patterns in C# and explore how you can automate them using Metalama.

## INotifyPropertyChanged

If you're building a desktop or mobile app, or even a web app with client-side Blazor, you're likely familiar with the `INotifyPropertyChanged` interface. While it seems simple to implement, it can become cumbersome and error-prone as you add more complex properties and dependencies between objects.

Enter the `[Observable]` aspect from the open-source [Metalama.Patterns.Observability](https://doc.postsharp.net/metalama/patterns/observability?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly) package.

```csharp
[Observable]
public class Person
```

This aspect handles `INotifyPropertyChanged` implementation for you, supporting a rich set of scenarios:

- **Automatic properties:**

    ```csharp
    public string? FirstName { get; set; }
    ```

- **Properties depending on other properties or fields:**

    ```csharp
    public string FullName => $"{this.FirstName} {this._lastName}";
    ```

- **Properties depending on child objects, such as `Person`:**

    ```csharp
    public string FullName => $"{this.Person.FirstName} {this.Person.LastName}";
    ```

- **Properties depending on properties of the base type.**

Consider how much boilerplate code you'd need to properly implement `INotifyPropertyChanged` for these scenarios and how much you would save with Metalama! To see the work Metalama does for you, [check out the diff](https://doc.postsharp.net/metalama/patterns/observability/standard-cases?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly).

It's not just about saving code, but also about enhancing code quality. Remember the last bug when you forgot to add a call to `OnPropertyChanged` for a computed property? With `[Observable]`, since dependency discovery is fully automatic, this won't happen any more.

Read more details about `[Observable]` in our [documentation](https://doc.postsharp.net/metalama/patterns/observability?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly).

## Builder Pattern

Another frequent source of boilerplate code is the [Builder pattern](https://blog.postsharp.net/builder-pattern-with-metalama?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly), which has become ubiquitous in modern C# due to the increased use of immutable types.

Consider a simple immutable class:

```csharp
public partial class Song
{
    public string Title { get; }

    public ImmutableArray<string> Artists { get; }
}
```

The code supporting the Builder class would look like this:

```csharp
public partial class Song
{
    private Song(string title, ImmutableArray<string> artists)
    {
        this.Title = title;
        this.Artists = artists;
    }

    public Builder ToBuilder() => new Builder(this);

    public class Builder
    {
        public string Title { get; set; }

        public ImmutableArray<string>.Builder Artists { get; }

        public Builder()
        {
            this.Artists = ImmutableArray.CreateBuilder<string>();
        }

        public Builder(Song song)
        {
            this.Title = song.Title;
            this.Artists = song.Artists.ToBuilder();
        }

        public Song Build() => new Song(this.Title, this.Artists.ToImmutable());
    }
}
```

How repetitive! Do you really want to write this code by hand? Thankfully, [this can be automated using Metalama](https://doc.postsharp.net/metalama/examples/builder?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly), and you can tailor the code generation pattern to fit your needs.

## Other Examples

We can't cover all use cases of Metalama in a single email, so before wrapping up this sequence, here's a list of Metalama use cases:

- [Parameter validation](https://doc.postsharp.net/metalama/examples/validation?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly) and [code contracts](https://doc.postsharp.net/metalama/patterns/contracts);
- [Logging](https://doc.postsharp.net/metalama/examples/log?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly);
- [Exception handling](https://doc.postsharp.net/metalama/examples/exception-handling?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly) with or without [Polly](https://doc.postsharp.net/metalama/examples/exception-handling/retry/retry-5);
- [Caching](https://doc.postsharp.net/metalama/patterns/caching?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly) and [memoization](https://doc.postsharp.net/metalama/patterns/memoization?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly);
- [INotifyPropertyChanged](https://doc.postsharp.net/metalama/patterns/observability), WPF [commands](https://doc.postsharp.net/metalama/patterns/wpf/command?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly), and [dependency properties](https://doc.postsharp.net/metalama/patterns/wpf/dependency-property?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly);
- [Architecture verification](https://doc.postsharp.net/metalama/conceptual/architecture?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly);
- [Change tracking](https://doc.postsharp.net/metalama/examples/change-tracking?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly) and the [Memento pattern](https://doc.postsharp.net/metalama/examples/memento?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly).
- [Cloning](https://doc.postsharp.net/metalama/examples/clone?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly);
- [Builder](https://doc.postsharp.net/metalama/examples/builde?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly), and [Singleton](https://doc.postsharp.net/metalama/examples/singleton?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly) patterns;
- [ToString](https://doc.postsharp.net/metalama/examples/tostring) generation.

For more use cases and open-source aspect implementations, visit the [Metalama Marketplace](https://www.postsharp.net/metalama/marketplace?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly).

## How to Get Started?

Start using Metalama today. Add the `Metalama.Framework` package to your project and activate _Metalama Free_, our free edition that lets you use up to three aspect types (e.g., logging, caching, and `INotifyPropertyChanged`) regardless of your project's size.

For a better development experience, download the optional [Visual Studio Tools for Metalama](https://www.postsharp.net/metalama/download?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly).

If you have any questions, feel free to reach out to our community on [GitHub](https://github.com/orgs/postsharp/discussions) or on our [Slack workspace](https://www.postsharp.net/slack?mtm_campaign=awareness&mtm_kwd=email5&mtm_source=instantly).

Happy meta-programming with Metalama!
