# Common Tasks: Meeting Requirements

It's not uncommon for developers to have to ensure that certain key properties or return values actually have a value. Although the code required to perform the checks needed to ensure that a value is present are not difficult to write they do have the effect of of making your code look cluttered.

A typical string property might end up looking like this.

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

Metalama can make this task much simpler. Using exactly the same string property as an example you would just require the following.

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

Not only is the code cleaner but it is immediately apparent to anyone reading it that the UserName property is actively required in the overall working of the application. That is something that cannot be inferred as quickly by looking at the first example.

At compile time Metalama will add all the code that is necessary to ensure that the UserName property must be present.

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

Metalama has actually reinforced the check on our behalf ensuring that there is a clear distinction between a null value being passed to the property and a simple space making it easier to diagnose errors.

Metalama has a wide range of pre-built contracts that you can use in situations like this where it is necessary to ensure that fields, properties, parameters or return values meet certain conditions. In every case all you need to do is add the relevant attribute to you code in the correct place and Metalama will add the necessary additional code at compile time. Examples include phone, email and credit card number checks to name but three.

Doing this manually is time consuming and it can be prone to error. Metalama removes the chore of writing repetitive code, makes your intention clearer to anyone else who reads your code at a later date and leaves you safe in the knowledge that it will just work as it should when required.

<br>

If you'd like to know more about Metalama in general then visit our [website](https://www.postsharp.net/metalama).

You can learn more about Metalama contracts [here](https://doc.postsharp.net/metalama/patterns/contracts).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
