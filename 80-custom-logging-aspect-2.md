# Creating Aspects: Practical Logging

Logging can be very useful when it comes to debugging our code but simply writing to the console is a little restrictive. It would be better if we were to make use of one of the popular logging frameworks to record our output for future reference and one of the best ways to do that is to make use of Microsoft's ILogger interface. This will involve using dependency injection in our aspect which is very simple with Metalama.

As in the previous example we'll be creating string based log messages so we'll make use of the InterpolatedStringBuilder again, however our aspect will be different.

```c#
using Metalama.Extensions.DependencyInjection;
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using Metalama.Framework.Code.SyntaxBuilders;
using Microsoft.Extensions.Logging;

namespace CreatingAspects.Logging
{
    public class LogAttribute : OverrideMethodAspect
    {

        [IntroduceDependency]
        private readonly ILogger _logger;

        public override dynamic? OverrideMethod()
        {
            // Determine if tracing is enabled.
            var isTracingEnabled = this._logger.IsEnabled(LogLevel.Trace);

            // Write entry message.
            if(isTracingEnabled)
            {
                var entryMessage = BuildInterpolatedString(false);
                entryMessage.AddText(" started.");
                this._logger.LogTrace((string)entryMessage.ToValue());
            }

            try
            {
                // Invoke the method and store the result in a variable.
                var result = meta.Proceed();

                if(isTracingEnabled)
                {
                    // Display the success message. The message is different when the method is void.
                    var successMessage = BuildInterpolatedString(true);

                    if(meta.Target.Method.ReturnType.Is(typeof(void)))
                    {
                        // When the method is void, display a constant text.
                        successMessage.AddText(" succeeded.");
                    } else
                    {
                        // When the method has a return value, add it to the message.
                        successMessage.AddText(" returned ");
                        successMessage.AddExpression(result);
                        successMessage.AddText(".");
                    }

                    this._logger.LogTrace((string)successMessage.ToValue());
                }

                return result;
            } catch(Exception e) when (this._logger.IsEnabled(LogLevel.Warning))
            {
                // Display the failure message.
                var failureMessage = BuildInterpolatedString(false);
                failureMessage.AddText(" failed: ");
                failureMessage.AddExpression(e.Message);
                this._logger.LogWarning((string)failureMessage.ToValue());

                throw;
            }
        }

        // Add the InterpolateStringBuilder here.

    }
}
```

This aspect is more complicated than those we have created to date and it warrants some explanation.

To start with in order to support Dependency Injection we have pulled in the Metalama.Extensions.DependencyInjection package as well as the Microsoft.Extensions.Logging package to enable us to use the ILogger interface and that allows us to use the `[InjectDependency]` attribute to add the ILogger.

The OverrideMethod method is a Metalama template which as you'll recall allows us to mix both runtime and compile time code allowing us to add the boolean variable isTracingEnabled (set by referencing the LogLevel applied to the ILogger instance) and at runtime that will be used to determine whether or not any logging will actually take place.

> Logging can be an expensive process and it is better to log sparingly but retain the option to log comprehensively when necessary.

In our aspect the bulk of the logging is wrapped conditionally on a Log Level of trace which would rarely be set but the exception is conditionally wrapped around a Log Level of warning which will almost always be met thus ensuring that errors will always be recorded in the log.

When applied to the following example;

```c#
namespace CreatingAspects.Logging
{
    public  partial class Calculator
    {


        [Log]
        public  double Divide(int a, int b) { return a / b; }

        [Log]
        public  void IntegerDivide(int a, int b, out int quotient, out int remainder)
        {
            quotient = a / b;
            remainder = a % b;
        }


    }
}
```

Metalama will add the following at compile time;

```c#
using Microsoft.Extensions.Logging;

namespace CreatingAspects.Logging
{
    public  partial class Calculator
    {


        [Log]
        public  double Divide(int a, int b) {     var isTracingEnabled = this._logger.IsEnabled(LogLevel.Trace);
            if (isTracingEnabled)
            {
                LoggerExtensions.LogTrace(this._logger, $"Calculator.Divide(a = {{{a}}}, b = {{{b}}}) started.");
            }

            try
            {
                double result;
                result = a / b;

                if (isTracingEnabled)
                {
                    LoggerExtensions.LogTrace(this._logger, $"Calculator.Divide(a = {{{a}}}, b = {{{b}}}) returned {result}.");
                }

                return (double)result;
            }
            catch (Exception e) when (this._logger.IsEnabled(LogLevel.Warning))
            {
                LoggerExtensions.LogWarning(this._logger, $"Calculator.Divide(a = {{{a}}}, b = {{{b}}}) failed: {e.Message}");
                throw;
            }
        }

        [Log]
        public  void IntegerDivide(int a, int b, out int quotient, out int remainder)
        {
            var isTracingEnabled = this._logger.IsEnabled(LogLevel.Trace);
            if (isTracingEnabled)
            {
                LoggerExtensions.LogTrace(this._logger, $"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = <out> , remainder = <out> ) started.");
            }

            try
            {
                quotient = a / b;
            remainder = a % b;

                object result = null;
                if (isTracingEnabled)
                {
                    LoggerExtensions.LogTrace(this._logger, $"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = {{{quotient}}}, remainder = {{{remainder}}}) succeeded.");
                }

                return;
            }
            catch (Exception e) when (this._logger.IsEnabled(LogLevel.Warning))
            {
                LoggerExtensions.LogWarning(this._logger, $"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = <out> , remainder = <out> ) failed: {e.Message}");
                throw;
            }
        }


        private ILogger _logger;

        public Calculator
        (ILogger<Calculator> logger = default)
        {
            this._logger = logger ?? throw new System.ArgumentNullException(nameof(logger));

        }

    }
}
```

Observe how Metalama has added the necessary constructor to instantiate the ILogger and correctly handled a possible exception. Metalama makes Dependency Injection as simple as adding a single attribute, comprehensively described [here](https://doc.postsharp.net/metalama/conceptual/aspects/dependency-injection).
