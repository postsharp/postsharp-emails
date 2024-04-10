# Creating Aspects: Practical Logging

Logging can be highly beneficial for debugging code. However, merely writing to the console can be limiting. It's more advantageous to utilize one of the popular logging frameworks to record our output for future reference. One of the best ways to achieve this is by using Microsoft's ILogger interface. This process involves the use of dependency injection in our aspect, which is straightforward with Metalama.

As in the previous example, we'll be creating string-based log messages, so we'll use the InterpolatedStringBuilder again. However, our aspect will differ.

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

This aspect is more complex than those we have created so far, and it warrants some explanation.

Firstly, to support Dependency Injection, we have incorporated the Metalama.Extensions.DependencyInjection package and the Microsoft.Extensions.Logging package. This enables us to use the ILogger interface and the `[InjectDependency]` attribute to add the ILogger.

The OverrideMethod method is a Metalama template, which, as you may remember, allows us to blend runtime and compile-time code. This lets us add the boolean variable isTracingEnabled (set by referencing the LogLevel applied to the ILogger instance). At runtime, this variable will determine whether any logging will actually occur.

> Logging can be an expensive process, and it is better to log sparingly but retain the option to log comprehensively when necessary.

In our aspect, the majority of the logging is conditionally wrapped around a Log Level of trace, which would rarely be set. However, the exception is conditionally wrapped around a Log Level of warning, which will almost always be met. This ensures that errors will always be recorded in the log.

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
        public void IntegerDivide(int a, int b, out int quotient, out int remainder)
        {
            var isTracingEnabled = this._logger.IsEnabled(LogLevel.Trace);
            if (isTracingEnabled)
            {
                LoggerExtensions.LogTrace(this._logger, $"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = <out>, remainder = <out>) started.");
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
                LoggerExtensions.LogWarning(this._logger, $"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = <out>, remainder = <out>) failed: {e.Message}");
                throw;
            }
        }

        private ILogger _logger;

        public Calculator(ILogger<Calculator> logger = default)
        {
            this._logger = logger ?? throw new System.ArgumentNullException(nameof(logger));
        }

    }
}
```

Note how Metalama has added the necessary constructor to instantiate the `ILogger` and has correctly handled a potential exception. Metalama simplifies Dependency Injection to the addition of a single attribute, which is comprehensively described [here](https://doc.postsharp.net/metalama/conceptual/aspects/dependency-injection).

