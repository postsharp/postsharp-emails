# Creating Custom Aspects: Multi-targeting

After reading our introduction to creating custom aspects, you might have been left with the impression that you need to create separate aspects for each target (field, property, method, or type). However, that's not the case. You can create a single aspect that targets multiple elements, but it requires you to use a slightly different signature for your aspect.

To illustrate this, let's consider a simple example where we want to log the fact that a property or a method has been accessed.

The basic signature of the aspect will look like this:

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

In this example, we're inheriting directly from `System.Attribute` and implementing Metalama's `IAspect<T>` interface for both methods and fields or properties. We're also explicitly stating where the attribute should be used.

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

Here, we're adding specific methods to build the aspects that will be applied to methods or properties. Each method takes a builder object as a parameter, which is used to add the actual advice to them.

Once these methods have been fleshed out, they should look like this:

```c#
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Property)]
public class LogAttribute : Attribute, IAspect<IMethod>, IAspect<IFieldOrProperty>
{

    public void BuildAspect(IAspectBuilder<IMethod> builder)
    { 
        builder.Advice.Override(builder.Target, nameof(this.OverrideMethod)); 
    }

    public void BuildAspect(IAspectBuilder<IFieldOrProperty> builder)
    { 
        builder.Advice.Override(builder.Target, nameof(this.OverrideProperty)); 
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

The builder adds advice to the chosen targets via methods which are themselves decorated with the `[Template]` attribute. Without going into too much detail, Metalama Templates integrate both compile-time and runtime code.

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

Running this code in a console app:

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

Produces this result:

```
You have entered Order.GenerateOrderNumber
The old value of Order was: int = 0
The new value of Order is: int = 59
```
