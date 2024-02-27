# Common Tasks: Verifying Required Parameters and Fields

Developers often need to ensure that certain key properties or return values have a value. Although the code required to perform these checks isn't complex, it can clutter your code.

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
            if (!string.IsNullOrWhiteSpace(value))
            {
                userName = value;
            }
            else
            {
                throw new ArgumentException("Invalid value for MyString. Value must not be null or blank.");
            }
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

Not only is the code cleaner, but it's also immediately apparent that the UserName property is required for the application's operation. This isn't as quickly inferred from the first example.

At compile time, Metalama will add all the necessary code to ensure that the UserName property must be present.

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

Metalama reinforces the check, ensuring a clear distinction between a null value being passed to the property and a simple space, making it easier to diagnose errors.

Metalama has a wide range of pre-built contracts that you can use in situations where it's necessary to ensure that fields, properties, parameters, or return values meet certain conditions. In every case, all you need to do is add the relevant attribute to your code in the correct place, and Metalama will add the necessary additional code at compile time. Examples include phone, email, and credit card number checks.

Doing this manually is time-consuming and can be prone to error. Metalama removes the chore of writing repetitive code, makes your intention clearer to anyone else who reads your code later, and ensures that it will work as expected when required.

<br>

If you'd like to know more about Metalama in general, visit our [website](https://www.postsharp.net/metalama).

You can learn more about Metalama contracts [here](https://doc.postsharp.net/metalama/patterns/contracts).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
