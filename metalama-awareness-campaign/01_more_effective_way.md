---
subject: 'Discover Metalama: A New Code Generation Framework for C#'
layout: instantly
---

{% raw %}

Hi {{firstName}},

I'm **{{sendingAccountFirstName}}**, reaching out on behalf of our founder to gather feedback from experienced .NET engineers like you about [Metalama](https://metalama.net?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email1), an open source meta-programming framework for code generation, architecture validation, and aspect-oriented programming in C#.

As someone who works with .NET, you know how repetitive patterns and boilerplate can slow down development, clutter codebases, and, hinder its maintenanbility -- although maintenance typically counts for 70% of the total cost of enterprise projects. Metalama is designed to help you eliminate that friction by letting you write special custom attributes, called **aspects**, that act as code templates. Here’s a quick look at a simple logging aspect:

```csharp
using Metalama.Framework.Aspects;

public class LogAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        Console.WriteLine($"Entering {meta.Target.Method}.");
        try
        {
            return meta.Proceed();
        }
        finally
        {
            Console.WriteLine($"Leaving {meta.Target.Method}.");
        }
    }
}
```

You can apply this aspect to any method:

```csharp
[Log]
void SomeMethod() => Console.WriteLine("Hello, World!");
```

At compile time, Metalama transforms your code into this:

```csharp
void SomeMethod()
{
    Console.WriteLine("Entering Program.SomeMethod()");
    try
    {
        Console.WriteLine("Hello, World!");
    }
    finally
    {
        Console.WriteLine("Leaving Program.SomeMethod()");
    }
}
```

With Metalama, you can preview and debug generated code, making it easy to see exactly what is happening under the hood. The real power lies in how much repetitive code you can eliminate, and how quickly you can adapt patterns across your codebase by updating a single aspect class instead of potentially hundreds or thousands of implementations.

**Why choose Metalama?**

**Reduce code and bugs by 15%.** Let the machine handle repetitive tasks so engineers can focus on meaningful work.

**Maintain clean and readable code.** Simplify your codebase for better maintainability and collaboration.

**Enforce architectural consistency.** Define validation rules in C# and receive instant feedback directly in your IDE.

If you have ever wished for a more effective way to handle logging, validation, or other cross-cutting concerns, Metalama is designed for you. There are [dozens of use cases](https://metalama.net/applications?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email1) in any non-trivial application. Explore our [documentation](https://doc.metalama.net/conceptual/getting-started?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email1) and [commented examples](https://doc.metalama.net/examples?mtm_campaign=awareness&mtm_source=instantly&mtm_kwd=email1) to learn more.

We would love to hear your thoughts, questions, or feedback. Join the conversation on our [GitHub discussion space](https://github.com/orgs/metalama/discussions/categories/q-a), or simply reply to this email and I will connect you directly with our engineering team.

Thank you for your time.

Best regards,
**{{sendingAccountFirstName}}**
Community Manager

*P.S. We will send you four more emails about Metalama and then stop. You can unsubscribe at any time.*

{% endraw %}