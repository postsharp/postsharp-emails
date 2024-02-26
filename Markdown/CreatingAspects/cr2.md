# Creating Custom Aspects: Multi-targeting

It's possible after having read our introduction to creating custom aspects that you might have been left thinking that you have to create separate aspects for each thing (field, property, method or type) that you want to target.

As it happens that isn't the case but it does require you to use a slightly different signature for your aspect.

To illustrate the point let's consider a very simple example where we would like to log the fact that a property or a method has been accessed.

The basic signature of the aspect will look like this.

<br>

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

<br>

As you can see we are inheriting directly from System.Attribute and implementing Metalama's `IAspect<T>` interface for both Methods and FieldsOrProperties. We are also explicitly stating where the attribute should be used.

To implement the interfaces we need to explicitly add the following.

<br>

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

<br>

Here we adding specific methods to build the aspects that will be applied to Methods or properties respectively. Each takes a builder object as a parameter which is used to add the actual advice to them.

When these methods have been fleshed out.

<br>

```c#
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Property)]
public class LogAttribute : Attribute, IAspect<IMethod>, IAspect<IFieldOrProperty>
{

    public void BuildAspect(IAspectBuilder<IMethod> builder)
    { builder.Advice.Override(builder.Target, nameof(this.OverrideMethod)); }

    public void BuildAspect(IAspectBuilder<IFieldOrProperty> builder)
    { builder.Advice.Override(builder.Target, nameof(this.OverrideProperty)); }

    [Template]
    public dynamic? OverrideMethod()
    {
        var methodName = $"{meta.Target.Type.ToDisplayString(CodeDisplayFormat.MinimallyQualified)}.{meta.Target.Method.Name}";
        try
        {
            Console.WriteLine($"You have entered {methodName}");
            return meta.Proceed();
        } catch(Exception ex)
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
                $"The value of {meta.Target.Type.ToDisplayString(CodeDisplayFormat.MinimallyQualified)}.{meta.Target.Property.Name} is: {meta.Target.Property.Type} = {meta.Target.Property.Value}");
            return result;
        }
        set

        {
            Console.WriteLine(
                $"The old value of {meta.Target.Type.ToDisplayString(CodeDisplayFormat.MinimallyQualified)} was: {meta.Target.Property.Type} = {meta.Target.Property.Value}");

            meta.Proceed();

            Console.WriteLine(
                $"The new value of {meta.Target.Type.ToDisplayString(CodeDisplayFormat.MinimallyQualified)} is: {meta.Target.Property.Type} = {meta.Target.Property.Value}");
        }
    }
}
```

<br>

The builder adds advice to the chosen targets via methods which are themselves decorated with the `[Template]` attribute. Without going into too much detail here Metalama Templates integrate both compile time and run time code.

Logging could now be applied to a simple Order class;

<br>

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

<br>

Which when compiled would look like this.

<br>

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

<br>

Running this code in a console app

<br>

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

Produces this result;

```
You have entered Order.GenerateOrderNumber
The old value of Order was: int = 0
The new value of Order is: int = 59
```

<br>

If you'd like to know more about Metalama in general then visit our [website](https://www.postsharp.net/metalama).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
