---
subject: "Practical Logging with Dependency Injection"
---

Logging is often used as a _Hello, world_ example for aspect-oriented programming, and this email course is no exception. In previous emails, we took the simple approach of using `Console.WriteLine`. However, in production code, you would typically use a more robust solution. Nowadays, the most common way to log is by using the `ILogger` interface from the `Microsoft.Extensions.Logging` namespace.

To use `ILogger`, you need to introduce a dependency on `ILogger` in your aspect. This is straightforward with Metalama. Simply add a field of type `ILogger` to your aspect and annotate it with the `[IntroduceDependency]` attribute.

Let’s see this in action with a simplified logging aspect:

```c#
using Metalama.Extensions.DependencyInjection;
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using Metalama.Framework.Code.SyntaxBuilders;
using Microsoft.Extensions.Logging;

public class LogAttribute : OverrideMethodAspect
{
    [IntroduceDependency]
    private readonly ILogger? _logger;

    public override dynamic? OverrideMethod()
    {
        // Determine if tracing is enabled.
        var isTracingEnabled = this._logger?.IsEnabled(LogLevel.Trace) == true;

        // Write entry message.
        if (isTracingEnabled)
        {
            this._logger.LogTrace($"{meta.Target.Method}: Executing.");
        }

        try
        {
            // Invoke the method and store the result in a variable.
            var result = meta.Proceed();

            if (isTracingEnabled)
            {
                this._logger.LogTrace($"{meta.Target.Method}: Completed.");
            }

            return result;
        }
        catch (Exception e) when (this._logger?.IsEnabled(LogLevel.Warning) == true)
        {
            // Log the failure message.
            this._logger.LogWarning($"{meta.Target.Method}: {e.Message}.");
            throw;
        }
    }
}
```

We intentionally made the `_logger` field nullable, which implicitly makes the `ILogger` dependency optional. This ensures that our code can function even without logging.

The `OverrideMethod` method is a Metalama template that allows us to blend runtime and compile-time code. This enables us to add the `isTracingEnabled` boolean variable (set by calling `ILogger.IsEnabled`). At runtime, this variable determines whether any logging will actually occur. Since logging can be an expensive process, it’s better to log sparingly while retaining the option to log comprehensively when needed.

In our aspect, most of the logging is conditionally wrapped around the _Trace_ log level, which is rarely enabled. However, exception logging is wrapped around the _Warning_ log level, which is almost always enabled. This ensures that errors are consistently recorded in the log.

When applied to the following example:

```c#
public class Calculator
{
    [Log]
    public double Divide(int a, int b) { return a / b; }

    [Log]
    public void IntegerDivide(int a, int b, out int quotient, out int remainder)
    {
        quotient = a / b;
        remainder = a % b;
    }
}
```

Metalama will generate the following code at compile time:

```c#
using Microsoft.Extensions.Logging;

public class Calculator
{
    [Log]
    public double Divide(int a, int b)
    {
        var isTracingEnabled = this._logger?.IsEnabled(LogLevel.Trace) == true;
        if (isTracingEnabled)
        {
            LoggerExtensions.LogTrace(this._logger, "Calculator.Divide(int, int): Executing.");
        }

        try
        {
            double result = a / b;
            if (isTracingEnabled)
            {
                LoggerExtensions.LogTrace(this._logger, "Calculator.Divide(int, int): Completed.");
            }

            return result;
        }
        catch (Exception e) when (this._logger?.IsEnabled(LogLevel.Warning) == true)
        {
            LoggerExtensions.LogWarning(this._logger, $"Calculator.Divide(int, int): {e.Message}.");
            throw;
        }
    }

    [Log]
    public void IntegerDivide(int a, int b, out int quotient, out int remainder)
    {
        var isTracingEnabled = this._logger?.IsEnabled(LogLevel.Trace) == true;
        if (isTracingEnabled)
        {
            LoggerExtensions.LogTrace(this._logger, "Calculator.IntegerDivide(int, int, out int, out int): Executing.");
        }

        try
        {
            quotient = a / b;
            remainder = a % b;
            if (isTracingEnabled)
            {
                LoggerExtensions.LogTrace(this._logger, "Calculator.IntegerDivide(int, int, out int, out int): Completed.");
            }
        }
        catch (Exception e) when (this._logger?.IsEnabled(LogLevel.Warning) == true)
        {
            LoggerExtensions.LogWarning(this._logger, $"Calculator.IntegerDivide(int, int, out int, out int): {e.Message}.");
            throw;
        }
    }

    private ILogger _logger;

    public Calculator(ILogger<Calculator>? logger = default)
    {
        this._logger = logger;
    }
}
```

Note how Metalama automatically adds the necessary constructor to inject the `ILogger` dependency.

As you can see, using dependency injection with Metalama is straightforward. For more details, refer to the [conceptual documentation](https://doc.metalama.net/conceptual/aspects/dependency-injection).

