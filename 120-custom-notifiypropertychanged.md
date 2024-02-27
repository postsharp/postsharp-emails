# Automating INotifyPropertyChanged On Your Terms

In the previous emails, you first learned how to create simple aspects by deriving from `OverrideMethodAspect`, then more complex aspects by implementing the `IAspect<T>` interface and its `BuildAspect` method yourself. Today, we will see how to create aspects that apply _several_ modifications to the target code, i.e., supply several pieces of advice. As an example, we will take the implementation of the `INotifyPropertyChanged` interface, which requires three different operations on the target type and its properties.

Let me first introduce `INotifyPropertyChanged`.

We've come to expect application user interfaces to respond almost instantaneously to the data that we input. This is made possible by UIs built around data-bound controls in architecture that implements patterns such as MVVM (Model, View, ViewModel). In simple terms, this works because the UI updates when properties in the underlying data models change, thereby raising the PropertyChanged event. This logic is encapsulated in the INotifyPropertyChanged interface. This pattern has been widely adopted as it allows for the reuse of data models with different views.

However, there's a notable drawback to using this interface. It requires a great deal of repetitive boilerplate code, which isn't produced automatically, making it possible to unintentionally omit parts of it.

The .NET class library already has an INotifyPropertyChanged interface, so why not just use that? The drawback to this approach is illustrated below.

![](images/notifypropertychanged1.gif)

The standard Visual Studio intellisense for this barely does anything. There's still a need to adjust the properties so that they actually raise the event, and the event itself needs to be handled.

If Metalama is used to implement `INotifyPropertyChanged`, all of the additional code required to make this work will be taken care of. It will be necessary to create an aspect to do this, but fortunately, there's a great example of such an aspect in the [Metalama Documentation](https://doc.postsharp.net/metalama/examples/notifypropertychanged).

```c#
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using System.ComponentModel;

namespace CommonTasks.NotifyPropertyChanged
{
    [Inheritable]
    internal class NotifyPropertyChangedAttribute : TypeAspect
    {
        public override void BuildAspect(IAspectBuilder<INamedType> builder)
        {
            builder.Advice.ImplementInterface(builder.Target, typeof(INotifyPropertyChanged), OverrideStrategy.Ignore);

            foreach (var property in builder.Target.Properties.Where(p =>
                         !p.IsAbstract && p.Writeability == Writeability.All))
            {
                builder.Advice.OverrideAccessors(property, null, nameof(this.OverridePropertySetter));
            }
        }

        [InterfaceMember]
        public event PropertyChangedEventHandler? PropertyChanged;

        [Introduce(WhenExists = OverrideStrategy.Ignore)]
        protected void OnPropertyChanged(string name) =>
            this.PropertyChanged?.Invoke(meta.This, new PropertyChangedEventArgs(name));

        [Template]
        private dynamic OverridePropertySetter(dynamic value)
        {
            if (value != meta.Target.Property.Value)
            {
                meta.Proceed();
                this.OnPropertyChanged(meta.Target.Property.Name);
            }

            return value;
        }
    }
}
```


If you read through the aspect implementation, you'll see that:

1. First, it implements the `INotifyPropertyChanged` interface by calling `builder.Advice.ImplementInterface`. The members of the `INotifyPropertyChanged` interfaces must be implemented in the aspect class and have the  `[InterfaceMember]` custom attribute.
2. Then, it loops through the writable properties, amending their setters through `builder.Advice.OverrideAccessors` to apply the `OverridePropertySetter` template method.
3. Finally, it adds an `OnPropertyChanged` method to the target type thanks to the `[Introduce]` advice attribute.

With the aspect added to your project, the `INotifyPropertyChanged` implementation is greatly simplified.


![](images/notifypropertychanged2.gif)


In what was admittedly a small and contrived sample class, Metalama successfully implemented the `INotifyPropertyChanged` interface, saving us from adding 50 additional lines of code. Over the entirety of a larger, real-world example, the savings in writing repetitive boilerplate code will be considerable.

