# Creating Aspects: Practical Logging

Logging is often used as a _Hello, world_ example for aspect-oriented programming, and this email course is no exception. In previous emails, we took the simple path of using `Console.WriteLine`, but of course, you would never do that in production code. Nowadays, the most common way to log is to use the `ILogger` interface from the `Microsoft.Extensions.Logging` namespace.

To use `ILogger`, you need to introduce a dependency to `ILogger` in your aspect, which is straightforward with Metalama. All you have to do is add a field of `ILogger` type to your aspect, and annotate it with the `[IntroduceDependency]` attribute.

Let's see this in action with a simplified logging aspect.

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

            if(isTracingEnabled)
            {
                this._logger.LogTrace($"{meta.Target.Method}: Completed.");
            }

            return result;
        }
        catch (Exception e) when (this._logger?.IsEnabled(LogLevel.Warning) == true)
        {
            // Display the failure message.
            this._logger.LogWarning($"{meta.Target.Method}: {e.Message}.");

            throw;
        }
    }
}

```

We intentionally made the `_logger` field nullable, which implicitly makes the `ILogger` dependency optional. Indeed, our code can work perfectly _without_ logging.

The `OverrideMethod` method is a Metalama template that, as you may remember, allows us to blend runtime and compile-time code. This allows us to add the boolean variable `isTracingEnabled` (set by calling `ILogger.IsEnabled`). At runtime, this variable will determine whether any logging will actually occur. Logging can be an expensive process, so it's better to log sparingly but retain the option to log comprehensively when necessary.

In our aspect, most of the logging is conditionally wrapped around a log level of _Trace_, which would rarely be set. However, the exception is conditionally wrapped around a log level of _Warning_, which will almost always be met. This ensures that errors will always be recorded in the log.

When applied to the following example;

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

Metalama will add the following at compile time;

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
            double result;
            result = a / b;
            if (isTracingEnabled)
            {
                LoggerExtensions.LogTrace(this._logger, "Calculator.Divide(int, int): Completed.");
            }

            return (double)result;
        }
        catch (Exception e)when (this._logger?.IsEnabled(LogLevel.Warning) == true)
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
            object result = null;
            if (isTracingEnabled)
            {
                LoggerExtensions.LogTrace(this._logger, "Calculator.IntegerDivide(int, int, out int, out int): Completed.");
            }

            return;
        }
        catch (Exception e)when (this._logger?.IsEnabled(LogLevel.Warning) == true)
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

Note how Metalama has added the necessary constructor to pull in the `ILogger` dependency.

As you can see, using dependency injection with Metalama is straightforward. For more details, see the [conceptual documentation](https://doc.metalama.net/conceptual/aspects/dependency-injection).

