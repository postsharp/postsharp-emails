# Creating Aspects: Meaningful Logging

In an earlier article, we demonstrated a simple example of logging, which involved noting the name of a method being called. Now, we're going to delve deeper into logging and describe more options available to you when creating your own aspects.

In this example, we'll log not just the method name being called, but also any parameters (with their types) that are being passed into it, and any return value if relevant.

For now, we'll continue to output the messages to the console as strings. To facilitate their creation, we'll create an interpolated string builder that we can use in our aspect.

```c#
using Metalama.Framework.Code;
using Metalama.Framework.Code.SyntaxBuilders;

private static InterpolatedStringBuilder BuildInterpolatedString(bool includeOutParameters)
{
    var stringBuilder = new InterpolatedStringBuilder();

    // Include the type and method name.
    stringBuilder.AddText(meta.Target.Type.ToDisplayString(CodeDisplayFormat.MinimallyQualified));
    stringBuilder.AddText(".");
    stringBuilder.AddText(meta.Target.Method.Name);
    stringBuilder.AddText("(");
    var i = meta.CompileTime(0);

    // Include a placeholder for each parameter.
    foreach (var p in meta.Target.Parameters)
    {
        var comma = i > 0 ? ", " : "";

        if (p.RefKind == RefKind.Out && !includeOutParameters)
        {
            // When the parameter is 'out', we cannot read the value.
            stringBuilder.AddText($"{comma}{p.Name} = <out> ");
        }
        else
        {
            // Otherwise, add the parameter value.
            stringBuilder.AddText($"{comma}{p.Name} = {{");
            stringBuilder.AddExpression(p.Value);
            stringBuilder.AddText("}");
        }

        i++;
    }

    stringBuilder.AddText(")");

    return stringBuilder;
}
```

The code above is relatively straightforward, but there are a couple of points worth noting. The first is the use of the special 'meta' keyword, which enables us to access the elements in our source code. The second point is that Metalama cannot read the value of out parameters. This is entirely logical, given that these values would not be known at the time the code is compiled.

Now that we have our InterpolatedStringBuilder, we can create our revised logging aspect that will utilize it.

```c#
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using Metalama.Framework.Code.SyntaxBuilders;

namespace CreatingAspects.Logging
{
    public class LogAttribute : OverrideMethodAspect
    {
        public override dynamic? OverrideMethod()
        {
            // Write entry message.
            var entryMessage = BuildInterpolatedString(false);
            entryMessage.AddText(" started.");
            Console.WriteLine(entryMessage.ToValue());

            try
            {
                // Invoke the method and store the result in a variable.
                var result = meta.Proceed();

                // Display the success message. The message is different when the method is void.
                var successMessage = BuildInterpolatedString(true);

                if (meta.Target.Method.ReturnType.Is(typeof(void)))
                {
                    // When the method is void, display a constant text.
                    successMessage.AddText(" succeeded.");
                }
                else
                {
                    // When the method has a return value, add it to the message.
                    successMessage.AddText(" returned ");
                    successMessage.AddExpression(result);
                    successMessage.AddText(".");
                }

                Console.WriteLine(successMessage.ToValue());

                return result;
            }
            catch (Exception e)
            {
                // Display the failure message.
                var failureMessage = BuildInterpolatedString(false);
                failureMessage.AddText(" failed: ");
                failureMessage.AddExpression(e.Message);
                Console.WriteLine(failureMessage.ToValue());

                throw;
            }
        }

        // Add the InterpolatedStringBuilder here.
    }
}
```

In this aspect, we log the name of the method and any parameters that are being passed to it. The method then runs, and we go on to log the return value if the method is not void or an error message should one occur.

When the `[Log]` attribute is applied to the following code:

```c#
namespace CreatingAspects.Logging
{
    public static class Calculator
    {
        [Log]
        private static double Divide(int a, int b)
        {
            return a / b;
        }

        [Log]
        public static void IntegerDivide(int a, int b, out int quotient, out int remainder)
        {
            quotient = a / b;
            remainder = a % b;
        }
    }
}
```

That code will then be transformed at compile time to this:

```c#
namespace CreatingAspects.Logging
{
    public static class Calculator
    {
        [Log]
        private static double Divide(int a, int b)
        {
```csharp
Console.WriteLine($"Calculator.Divide(a = {{{a}}}, b = {{{b}}}) started.");
try
{
    double result;
    result = a / b;

    Console.WriteLine($"Calculator.Divide(a = {{{a}}}, b = {{{b}}}) returned {result}.");
    return (double)result;
}
catch (Exception e)
{
    Console.WriteLine($"Calculator.Divide(a = {{{a}}}, b = {{{b}}}) failed: {e.Message}");
    throw;
}
}

[Log]
public static void IntegerDivide(int a, int b, out int quotient, out int remainder)
{
    Console.WriteLine($"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = <out>, remainder = <out>) started.");
    try
    {
        quotient = a / b;
        remainder = a % b;

        object result = null;
        Console.WriteLine($"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = {{{quotient}}}, remainder = {{{remainder}}}) succeeded.");
        return;
    }
    catch (Exception e)
    {
        Console.WriteLine($"Calculator.IntegerDivide(a = {{{a}}}, b = {{{b}}}, quotient = <out>, remainder = <out>) failed: {e.Message}");
        throw;
    }
}
}
}
```

Now, if we run the following code:

```csharp
try
{
    Calculator.Divide(7, 3);
    Calculator.IntegerDivide(7, 3, out int quotient, out int remainder);
}
catch (Exception ex)
{
    Console.WriteLine(ex);
}
```

The following will be written to the console:

```
Program output

Calculator.Divide(a = {7}, b = {3}) started.
Calculator.Divide(a = {7}, b = {3}) returned 2.3333333333333335.
Calculator.IntegerDivide(a = {7}, b = {3}, quotient = <out>, remainder = <out>) started.
Calculator.IntegerDivide(a = {7}, b = {3}, quotient = {2}, remainder = {1}) succeeded.
```
