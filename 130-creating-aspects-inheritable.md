# Automatically Adding Aspects to Derived Types: Aspect Inheritance

In the previous email, we examined how Metalama can simplify the implementation of `INotifyPropertyChanged`, compared to relying solely on the help provided by IntelliSense. To achieve this, a specific Metalama aspect was created. You might have overlooked it when we first discussed it, but this aspect was decorated with the `[Inheritable]` aspect.

```c#
  [Inheritable]
  internal class NotifyPropertyChangedAttribute : TypeAspect
  {
    // Aspect code here
  }
```

By doing this, we ensured that the aspect could be inherited by classes derived from a class to which the `[NotifyPropertyChanged]` attribute had been added.

This means it's possible to create a very simple base class:

```c#
namespace CommonTasks.NotifyPropertyChanged
{
    [NotifyPropertyChanged]
    public abstract partial class NotifyChangedBase
    {
    }
}
```

This base class can be used as shown below.

![](images/us5.jpg)

As you can see, the derived classes now have aspects applied to them. If we invoke the 'Show Metalama Diff' tool, we will see the following:

```c#
namespace CommonTasks.NotifyPropertyChanged
{
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
}
```

And in the base class, we have the following:

```c#
using System.ComponentModel;

namespace CommonTasks.NotifyPropertyChanged
{
    [NotifyPropertyChanged]
    public abstract partial class NotifyChangedBase: INotifyPropertyChanged
    {
        protected void OnPropertyChanged(string name)
        {
            this.PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
        }

        public event PropertyChangedEventHandler? PropertyChanged;
    }
}
```

> Note: When using the `[Inheritable]` aspect, careful consideration must be given to potential issues in the derived classes if the aspect you wish to apply has already been applied. Specifically, you must pay attention to the `OverrideStrategy` parameters and properties (also named `WhenExists`).

Your codebase remains clean and uncluttered, but its intention is clear. At compile time, everything needed to implement `INotifyPropertyChanged`, in this instance, is applied correctly.
