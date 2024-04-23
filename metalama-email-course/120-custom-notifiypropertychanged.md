# Automating INotifyPropertyChanged on Your Terms

In the previous emails, you learned how to create simple aspects by deriving from `OverrideMethodAspect`. Then, you learned about more complex aspects by implementing the `IAspect<T>` interface and its `BuildAspect` method. Today, we will explore how to create aspects that apply _multiple_ modifications to the target code, i.e., provide several pieces of advice. For illustration, we will use the implementation of the `INotifyPropertyChanged` interface, which requires three different operations on the target type and its properties.

First, let's introduce `INotifyPropertyChanged`.

Application user interfaces are designed to respond almost instantaneously to the data we input. This is achievable due to UIs built around data-bound controls in architectures that implement patterns such as MVVM (Model, View, ViewModel). In simple terms, this works because the UI updates when properties in the underlying data models change, thereby triggering the `PropertyChanged` event. This logic is encapsulated in the `INotifyPropertyChanged` interface. This pattern has gained widespread acceptance due to its ability to reuse data models with different views.

However, using this interface has a significant drawback. It requires a large amount of repetitive boilerplate code, which is not generated automatically, making it possible to unintentionally omit parts of it.

The .NET class library already includes an `INotifyPropertyChanged` interface, so why not just use that? The drawback to this approach is illustrated below.

![](images/notifypropertychanged1.gif)

The standard Visual Studio's _implement interface_ code fix barely does anything. There's still a need to adjust the properties so that they actually raise the event, and the event itself needs to be handled.

By using Metalama to implement `INotifyPropertyChanged`, all of the additional code required to make this work will be handled. You will need to create an aspect to do this, but fortunately, there's a great example of such an aspect in the [Metalama Documentation](https://doc.postsharp.net/metalama/examples/notifypropertychanged).

```c#
using Metalama.Framework.Aspects;
using Metalama.Framework.Code;
using System.ComponentModel;

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

```

If you read through the `BuildAspect`'s implementation, you'll notice that:

1. It first implements the `INotifyPropertyChanged` interface by calling `builder.Advice.ImplementInterface`. The members of the `INotifyPropertyChanged` interface must be implemented in the aspect class and have the `[InterfaceMember]` custom attribute.
2. It then loops through the writable properties, modifying their setters through `builder.Advice.OverrideAccessors` to apply the `OverridePropertySetter` template method.
3. Finally, it adds an `OnPropertyChanged` method to the target type using the `[Introduce]` advice attribute.

With this aspect added to your project, the `INotifyPropertyChanged` implementation is greatly simplified.

![](images/notifypropertychanged2.gif)

In what was admittedly a small and contrived sample class, Metalama successfully implemented the `INotifyPropertyChanged` interface, saving us from adding 50 additional lines of code. Over the entirety of a larger, real-world example, the reduction in writing repetitive boilerplate code will be substantial.
