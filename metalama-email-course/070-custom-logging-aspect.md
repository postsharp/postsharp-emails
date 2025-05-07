---
subject: Logging Methods, Including Parameter Values
---

In a previous article, we demonstrated a simple example of `OverrideMethodAspect` that performed authorization. This example made minimal use of the `meta` model: it only invoked `meta.Proceed()` to continue with the method execution and used `meta.Target.Method.ToString()` to print the method name.

Today, we will dive deeper into logging and show how your meta-code can be much more expressive.

In this example, we will log not only the name of the method being called but also any parameters (along with their types) that are passed into it, as well as any return value, if applicable.

For now, we will output the messages to the console as _interpolated strings_. To facilitate this, we will create a helper method that generates an interpolated string containing the overridden method (exposed as `meta.Target.Method`) and its parameters (exposed as `meta.Target.Method.Parameters`).

```c#
using Metalama.Framework.Code;
using Metalama.Framework.Code.SyntaxBuilders;

public partial class LogAttribute
{
    private static InterpolatedStringBuilder BuildInterpolatedString(bool includeOutParameters)
    {
        var stringBuilder = new InterpolatedStringBuilder();

        // Include the type and method name.
        stringBuilder.AddText(meta.Target.Type.ToDisplayString(CodeDisplayFormat.MinimallyQualified));
        stringBuilder.AddText(".");
        stringBuilder.AddText(meta.Target.Method.Name);
        stringBuilder.AddText("(");
        var i = 0;

        // Include a placeholder for each parameter.
        foreach (var p in meta.Target.Method.Parameters)
        {
            var comma = i > 0 ? ", " : "";

            if (p.RefKind == RefKind.Out && !includeOutParameters)
            {
                // When the parameter is 'out', we cannot read its value.
                stringBuilder.AddText($"{comma}{p.Name} = <out>");
            }
            else
            {
                // Otherwise, add the parameter value.
                stringBuilder.AddText($"{comma}{p.Name} = ");
                stringBuilder.AddExpression(p.Value);
                stringBuilder.AddText("}");
            }

            i++;
        }

        stringBuilder.AddText(")");

        return stringBuilder;
    }
}
```

Now that we have our `InterpolatedStringBuilder`, we can create a revised logging aspect that utilizes it.

```c#
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using Metalama.Framework.Code.SyntaxBuilders;

public partial class LogAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        // Write the entry message.
        var entryMessage = BuildInterpolatedString(false);
        entryMessage.AddText(" started.");
        Console.WriteLine(entryMessage.ToValue());

        try
        {
            // Invoke the method and store the result in a variable.
            var result = meta.Proceed();

            // Display the success message. The message differs when the method is void.
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
}
```

In this aspect, we log the name of the method and any parameters passed to it. The method then executes, and we log the return value if the method is not void or an error message if an exception occurs.

As you can see, Metalama allows you to write complex templates with the full power of C# available at compile time for authoring templates. We call this C#-to-C# template language _T#_.

When the `[Log]` attribute is applied to the following code:

```c#
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
```

That code will then be transformed at compile time to this:

```c#
[Log]
public static double Divide(int a, int b)
{
    Console.WriteLine($"Calculator.Divide(a = {a}, b = {b}) started.");

    try
    {
        double result;
        result = a / b;

        Console.WriteLine($"Calculator.Divide(a = {a}, b = {b}) returned {result}.");
        return (double)result;
    }
    catch (Exception e)
    {
        Console.WriteLine($"Calculator.Divide(a = {a}, b = {b}) failed: {e.Message}");
        throw;
    }
}

[Log]
public static void IntegerDivide(int a, int b, out int quotient, out int remainder)
{
    Console.WriteLine($"Calculator.IntegerDivide(a = {a}, b = {b}, quotient = <out>, remainder = <out>) started.");

    try
    {
        quotient = a / b;
        remainder = a % b;

        Console.WriteLine($"Calculator.IntegerDivide(a = {a}, b = {b}, quotient = {quotient}, remainder = {remainder}) succeeded.");
        return;
    }
    catch (Exception e)
    {
        Console.WriteLine($"Calculator.IntegerDivide(a = {a}, b = {b}, quotient = <out>, remainder = <out>) failed: {e.Message}");
        throw;
    }
}
```

Now, if we execute the following code:

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

The console will output the following:

```text
Program output

Calculator.Divide(a = 7, b = 3) started.
Calculator.Divide(a = 7, b = 3) returned 2.3333333333333335.
Calculator.IntegerDivide(a = 7, b = 3, quotient = <out>, remainder = <out>) started.
Calculator.IntegerDivide(a = 7, b = 3, quotient = 2, remainder = 1) succeeded.
```

You now know how to create non-trivial templates with T#, Metalama's C#-to-C# template language.
