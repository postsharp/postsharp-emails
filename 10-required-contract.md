# Verifying Required Fields and Parameters With Metalama

Developers often need to ensure that certain key properties or return values are not null. Although the code required to perform these checks is not complex, it can clutter the codebase.

Consider a typical string property that might look like this:

```c#
public class ApplicationUser
{
    private string userName;

    public string UserName
    {
        get { return userName; }
        set
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new ArgumentException("Invalid value for MyString. Value must not be null or blank.");
            }

            userName = value;
        }
    }
}
```

Metalama can simplify this task. Using the same string property as an example, you would only need the following:

```c#
using Metalama.Patterns.Contracts;

namespace CommonTasks.Required
{
    public class ApplicationUser
    {
        [Required]
        public string UserName { get; set; }

    }
}
```

Not only is the code cleaner, but it also becomes immediately apparent that the `UserName` property is required for the application's operation. This inference isn't as quickly made from the first example.

At compile time, Metalama will add all the necessary code to ensure that the `UserName` property is assigned a non-empty value. The following is the code that is _executed_:

```c#
using Metalama.Patterns.Contracts;

namespace CommonTasks.Required
{
    public class ApplicationUser
    {
        private string _userName = default!;

        [Required]
        public string UserName
        {
            get
            {
                return this._userName;
            }
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    if (value == null!)
                    {
                        throw new ArgumentNullException("value", "The 'UserName' property is required.");
                    }
                    else
                    {
                        throw new ArgumentOutOfRangeException("value", "The 'UserName' property is required.");
                    }
                }

                this._userName = value;
            }
        }
    }
}
```

As you can see, Metalama generates the boilerplate code that validates the string before it is assigned. 

Metalama offers a wide range of pre-built contracts that you can use in situations where it's necessary to ensure that fields, properties, parameters, or return values meet certain conditions. In every case, all you need to do is add the relevant attribute to your code in the correct place, and Metalama will add the necessary additional code at compile time. Examples include `[Phone]`, `[Email]`, and `[CreditCard]` for strings, as well as attributes like `[Positive]`, `[StrictlyPositive]` or `[Range]` for numbers.

Performing these tasks manually is time-consuming and can be prone to error. Metalama eliminates the chore of writing repetitive code, makes your intention clearer to anyone else who reads your code later, and ensures that it will work as expected when required. Because the boilerplate is now generated _on the fly_ at compile time, you no longer need any boilerplate in your _source_ code. Your codebase is simpler, easier to read, and simpler to maintain.
