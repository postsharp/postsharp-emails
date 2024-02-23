# Common Tasks: Validating String Length

Inevitably almost every developer will be faced with the necessity to validate the length of a string prior to doing something with it, an obvious case in point would be specifying criteria for a password.

At this point it's not uncommon for new or relatively inexperienced developers to create a simple checking method to satisfy the immediate requirement.

```c#
bool ValidateString(string input)
{
    return input.length < 10 && input.length > 16;
}
```

If the requirement was that the string be no less than 10 characters in length and no more than 16 then undeniably it will produce a result. If at some point further on in the program another similar check is required then it's very easy to see how this might be copied and pasted with a a couple of alterations to match the next requirement.

Using Metalama this task can be easily solved, as it has a number of pre-made contracts for just this type of scenario.

You could write code as follows (using a simple console application as an example);

```c#
using Metalama.Patterns.Contracts;

namespace CommonTasks
{
    internal class Program
    {

        [StringLength(10, 16)]
        private static string? password;

        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("Enter your Password:  ");
                password = Console.ReadLine();
                Console.WriteLine("Your password meets the basic length requirement.");
            } catch(ArgumentException ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}
```

Metalama's StringLength aspect takes as parameters either a maximum, or a minimum and maximum length and in the event of a validation failure throws a System.ArgumentException.

At the point of compilation it adds the necessary logic into your code.

```c#
using Metalama.Patterns.Contracts;

namespace CommonTasks
{
    internal class Program
    {


        private static string? _password1;


        [StringLength(10, 16)]
        private static string? password
        {
            get
            {
                return Program._password1;


            }
            set
            {
                if (value != null && (value!.Length < 10 || value.Length > 16))
                {
                    throw new ArgumentException($"The  'password' property must be a string with length between {10} and {16}.", "value");
                }
                Program._password1 = value;


            }
        }
        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("Enter your Password:  ");
                password = Console.ReadLine();
                Console.WriteLine("Your password meets the basic length requirement.");
            }
            catch (ArgumentException ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}
```

The benefit of using Metalama to handle such tasks is that they are handled consistently whilst your own code remains concise, easy to read and comprehend.

<br>

If you'd like to know more about Metalama in general then visit our [website](https://www.postsharp.net/metalama).

You can learn more about Metalama contracts [here](https://doc.postsharp.net/metalama/patterns/contracts).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
