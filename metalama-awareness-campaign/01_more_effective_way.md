# Discover Metalama: A New Code Generation Toolkit for C#

Hi {{firstName}},

My name is **{{sendingAccountFirstName}}** and I’m helping PostSharp’s founder to gather feedback about **Metalama**, a new, free code generation and validation toolkit for C#.

Given your experience in .NET, I thought you might be interested to learn about it and, on our side, we’re eager to hear your opinion, therefore this cold email.

The idea behind Metalama is that you write custom attributes called **aspects**, which work as code templates. Here is our Hello World example: a logging aspect.

```csharp
using Metalama.Framework.Aspects;

public class LogAttribute : OverrideMethodAspect
{
  public override dynamic? OverrideMethod()
  {
    Console.WriteLine( "Entering {meta.Target.Method}." );
    try
    {
       return meta.Proceed();
    }
    finally
    {
       Console.WriteLine( "Leaving {meta.Target.Method}." );
    }
  }
}
```

You can then use the aspect on any method, like this:

```csharp
[Log]
void SomeMethod() => Console.WriteLine( "Hello, World!" );
```

Metalama transforms the code during compilation into this:

```csharp
void SomeMethod()
{
  Console.WriteLine( "Entering Program.SomeMethod()" );
  try
  {
    Console.WriteLine( "Hello, World!" );
  }
  finally
  {
  Console.WriteLine( "Leaving Program.SomeMethod()" );
  }
}
```

It’s possible to preview or even debug the code generated by Metalama. The real benefit of this approach is that you can **drastically reduce repetitive code**. And if you want to change the code generation pattern, you just need to change the aspect. You get the idea!

**Key Benefits of Metalama:**

-   **Reduce repetitive code**
-   **Easy code modifications**
-   **Real-time feedback and code modifications**
-   **Preview and debug generated code**

You can find the source code of this example, as well as more examples, on [GitHub](https://github.com/postsharp/Metalama.Demo/blob/master/src/01_Log/LogAttribute.cs?mtm_campaign=awareness&mtm_source=instantly). You can learn more about Metalama thanks to the [video tutorials](https://doc.postsharp.net/metalama/videos?mtm_campaign=awareness&mtm_source=instantly) and [commented examples](https://doc.postsharp.net/metalama/examples?mtm_campaign=awareness&mtm_source=instantly).

Our development team is looking forward to your feedback and questions on our [Slack community workspace](https://www.postsharp.net/slack?mtm_campaign=awareness&mtm_source=instantly). Of course, you can also answer this email and I’ll make sure it will reach an engineer.

Thank you!

All the best,
**{{sendingAccountFirstName}}**
Community Manager