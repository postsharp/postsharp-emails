# Logging Methods, Including Parameter Values

In a previous article, we demonstrated a simple example of `OverrideMethodAspect` that performed authorization. This example made minimal use of the `meta` model: it only invoked `meta.Proceed()` to continue with the method execution, and utilized `meta.Target.Method.ToString()` to print the method name.

Today, we will delve deeper into logging and explain that your meta-code can be much richer.

In this example, we will log not just the name of the method being called, but also any parameters (along with their types) that are being passed into it, and any return value, if applicable.

For now, we will output the messages to the console as _interpolated strings_. To facilitate their creation, we will create a helper method that generates an interpolated string containing the overridden method (exposed as `meta.Target.Method`) and its parameters (exposed as `meta.Target.Method.Parameters`).

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
        var i = meta.CompileTime(0);

        // Include a placeholder for each parameter.
        foreach (var p in meta.Target.Method.Parameters)
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

Now that we have our `InterpolatedStringBuilder`, we can create our revised logging aspect that will utilize it.

```c#
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using Metalama.Framework.Code.SyntaxBuilders;

public partial class LogAttribute : OverrideMethodAspect
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

In this aspect, we log the name of the method and any parameters that are being passed to it. The method then runs, and we proceed to log the return value if the method is not void or an error message if one occurs.

As you can see, Metalama allows you to write complex templates, with the full power of C# available at compile-time for you to author templates. We call this C#-to-C# template language _T#_.

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
    Console.WriteLine($"Calculator.IntegerDivide(a = {a}, b = {b}, quotient = <out>, remainder = <out>) has started.");

    try
    {
        quotient = a / b;
        remainder = a % b;

        Console.WriteLine($"Calculator.IntegerDivide(a = {a}, b = {b}, quotient = {quotient}, remainder = {remainder}) has succeeded.");
        return;
    }
    catch (Exception e)
    {
        Console.WriteLine($"Calculator.IntegerDivide(a = {a}, b = {b}, quotient = <out>, remainder = <out>) has failed: {e.Message}");
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

Calculator.Divide(a = 7, b = 3) has started.
Calculator.Divide(a = 7, b = 3) returned 2.3333333333333335.
Calculator.IntegerDivide(a = 7, b = 3, quotient = <out>, remainder = <out>) has started.
Calculator.IntegerDivide(a = 7, b = 3, quotient = 2, remainder = 1) has succeeded.
```

You now know how to create non-trivial templates with T#, Metalama's own C#-to-C# template language.
