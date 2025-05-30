---
subject: "Creating Custom Aspects: Multi-targeting"
---

After reading our introduction to creating custom aspects, you might think you need to create separate aspects for each target (field, property, method, or type). However, this is not the case. You can create a single aspect class that targets multiple elements, but it requires a slightly different approach.

To illustrate this, let's consider a simple example of a logging aspect that can be applied to either a method or a property.

The basic signature of the aspect looks like this:

```c#
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;

namespace CreatingAspects.SimpleLogs
{
    [AttributeUsage(AttributeTargets.Method | AttributeTargets.Property)]
    public class LogAttribute : Attribute, IAspect<IMethod>, IAspect<IFieldOrProperty>
    {
    }
}
```

In this example, we inherit directly from `System.Attribute` and implement Metalama's `IAspect<T>` interface for both methods and fields or properties. The `[AttributeUsage]` attribute explicitly specifies where the attribute can be applied.

To implement the interfaces, we need to add the following methods:

```c#
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Property)]
public class LogAttribute : Attribute, IAspect<IMethod>, IAspect<IFieldOrProperty>
{
    public void BuildAspect(IAspectBuilder<IMethod> builder)
    {
    }

    public void BuildAspect(IAspectBuilder<IFieldOrProperty> builder)
    {
    }
}
```

The `BuildAspect` methods are the _entry points_ of the aspect. The Metalama framework invokes one of these methods for each declaration to which the aspect is applied. The `BuildAspect` method is executed at _compile time_.

Next, we need to add two _templates_: one for a method and one for a property. Templates must be annotated with the `[Template]` attribute. As you know, templates can combine compile-time and run-time code.

Finally, we must edit the `BuildAspect` to instruct that Metalama must override the target method or property with the given template. This is done by calling the `builder.Advice.Override(target, template)` method.

If you look at the source code of the [OverrideMethodAspect](https://github.com/postsharp/Metalama.Framework/blob/HEAD/Metalama.Framework/Aspects/OverrideMethodAspect.cs
), which should already be familiar to you, you will find that this is exactly what this class is doing for methods, except that the template method is abstract.

Once the `BuildAspect` and template methods have been fleshed out, they should look like this:

```c#
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Property)]
public class LogAttribute : Attribute, IAspect<IMethod>, IAspect<IFieldOrProperty>
{

    public void BuildAspect(IAspectBuilder<IMethod> builder)
    {
        builder.Override(nameof(this.OverrideMethod));
    }

    public void BuildAspect(IAspectBuilder<IFieldOrProperty> builder)
    {
        builder.Override(nameof(this.OverrideProperty));
    }

    [Template]
    public dynamic? OverrideMethod()
    {
        var methodName = $"{meta.Target.Type}.{meta.Target.Method.Name}";
        try
        {
            Console.WriteLine($"You have entered {methodName}");
            return meta.Proceed();
        }
        catch(Exception ex)
        {
            Console.WriteLine($"An error was encountered in {methodName}");
            return null;
        }
    }

    [Template]
    public dynamic? OverrideProperty
    {
        get
        {
            var result = meta.Proceed();
            Console.WriteLine(
                $"The value of {meta.Target.Type}.{meta.Target.Property.Name} is: {meta.Target.Property.Type} = {meta.Target.Property.Value}");
            return result;
        }

        set
        {
            Console.WriteLine(
                $"The old value of {meta.Target.Type} was: {meta.Target.Property.Type} = {meta.Target.Property.Value}");

            meta.Proceed();

            Console.WriteLine(
                $"The new value of {meta.Target.Type} is: {meta.Target.Property.Type} = {meta.Target.Property.Value}");
        }
    }
}
```

Now, logging can be applied to a simple `Order` class:

```c#
namespace CreatingAspects.SimpleLogs
{
    internal class Order
    {
        public Order()
        {
        }

        [Log]
        public void GenerateOrderNumber()
        {
            Random random = new Random();

            int minValue = 1;
            int maxValue = 100;

            OrderNumber = random.Next(minValue, maxValue);
        }

        [Log]
        public int OrderNumber { get; set; }

    }
}
```

After compiling, the code would look like this:

```c#
namespace CreatingAspects.SimpleLogs
{
    internal class Order
    {
        public Order()
        {
        }

        [Log]
        private void GenerateOrderNumber()
        {
            try
            {
                Console.WriteLine("You have entered Order.GenerateOrderNumber");
                Random random = new Random();

            int minValue = 1;
            int maxValue = 100;

            OrderNumber = random.Next(minValue, maxValue);

                return;
            }
            catch (Exception ex)
            {
                Console.WriteLine("An error was encountered in Order.GenerateOrderNumber");
                return;
            }
        }


        private int _orderNumber;
        [Log]
        public int OrderNumber
        {
            get
            {
                var result = this._orderNumber;
                Console.WriteLine($"The value of Order.OrderNumber is: int = {this._orderNumber}");
                return result;

            }
            set
            {
                Console.WriteLine($"The old value of Order was: int = {this._orderNumber}");
                this._orderNumber = value;
                Console.WriteLine($"The new value of Order is: int = {this._orderNumber}");

            }
        }
    }
}
```

When the following code is run in a console application:

```c#
namespace CreatingAspects.SimpleLogs
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Order order = new Order();
            order.GenerateOrderNumber();
        }
    }
}
```

It will produce the following output:

```text
You have entered Order.GenerateOrderNumber
The old value of Order was: int = 0
The new value of Order is: int = 59
```

As you can see, Metalama is more powerful than it may initially appear. Classes such as `OverrideMethodAspect` serve as API sugar. For Metalama, what really matters are the `IAspect<T>` interface and the operations performed by the `IAspect<T>.BuildAspect` method. This method can add advice to the target, such as overriding a member with a template, implementing a new interface, or adding a new member. They can also report warnings or errors, suggest code fixes, validate references, and add chil aspects. You can discover this in the documentation of the [IAspectBuilder](https://doc.metalama.net/api/metalama-framework-aspects-iaspectbuilder) class.
