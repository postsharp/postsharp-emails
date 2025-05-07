---
subject: "Automatically Adding Aspects to Derived Types: Aspect Inheritance"
---

In the previous email, we explored how Metalama simplifies the implementation of `INotifyPropertyChanged` compared to relying solely on IntelliSense. To achieve this, we created a specific Metalama aspect. You might have missed it when we first introduced it, but this aspect was decorated with the `[Inheritable]` attribute.

```c#
[Inheritable]
internal class NotifyPropertyChangedAttribute : TypeAspect
{
    // Aspect code here
}
```

By using this attribute, we ensured that the aspect could be inherited by classes derived from a class to which the `[NotifyPropertyChanged]` attribute had been applied.

This allows us to create a very simple base class:

```c#
[NotifyPropertyChanged]
public abstract partial class NotifyChangedBase
{
}
```

This base class can then be utilized as shown below:

![](images/us5.jpg)

As you can see, the derived classes now have aspects applied to them. If we invoke the 'Show Metalama Diff' tool, we will observe the following:

```c#
public partial class Customer : NotifyChangedBase
{
    private string? _address;
    public string? Address
    {
        get
        {
            return this._address;
        }
        set
        {
            if (value != this._address)
            {
                this._address = value;
                this.OnPropertyChanged("Address");
            }
        }
    }

    private string? _customerName;
    public string? CustomerName
    {
        get
        {
            return this._customerName;
        }
        set
        {
            if (value != this._customerName)
            {
                this._customerName = value;
                this.OnPropertyChanged("CustomerName");
            }
        }
    }
}

public partial class Order : NotifyChangedBase
{
    private DateTime _orderDate;
    public DateTime OrderDate
    {
        get
        {
            return this._orderDate;
        }
        set
        {
            if (value != this._orderDate)
            {
                this._orderDate = value;
                this.OnPropertyChanged("OrderDate");
            }
        }
    }

    private DateTime _requiredBy;
    public DateTime RequiredBy
    {
        get
        {
            return this._requiredBy;
        }
        set
        {
            if (value != this._requiredBy)
            {
                this._requiredBy = value;
                this.OnPropertyChanged("RequiredBy");
            }
        }
    }
}
```

The base class contains the following implementation:

```c#
using System.ComponentModel;

[NotifyPropertyChanged]
public abstract partial class NotifyChangedBase : INotifyPropertyChanged
{
    protected void OnPropertyChanged(string name)
    {
        this.PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }

    public event PropertyChangedEventHandler? PropertyChanged;
}
```

{. note }
When using the `[Inheritable]` aspect, careful consideration should be given to potential conflicts in derived classes if the aspect you wish to apply has already been applied. Specifically, you must pay attention to the `OverrideStrategy` parameters and properties (also named `WhenExists`).

This approach keeps your codebase clean and uncluttered while maintaining clear intent. At compile time, everything needed to implement `INotifyPropertyChanged` is applied correctly.
