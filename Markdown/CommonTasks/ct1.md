# Common Tasks: Input / Output Validation

Many developers will be familiar with the phrase 'Garbage in, garbage out'. In essence if the input being entered into an application is rubbish one shouldn't be surprised if what comes out is rubbish as well. To avoid this developers' need to ensure that what goes into their application's routines meet acceptable criteria and equally what comes out does the same.

Validation is a task that every developer will face at some point and the approach that they take is more often than not a good indication of their overall development experience.

As an example consider a basic requirement that a given string must fall within a given number of characters.

A new or relatively inexperienced developers might create a simple checking method to satisfy the immediate requirement.

<br>

```c#
bool ValidateString(string input)
{
    return input.length < 10 && input.length > 16;
}
```

<br>

If the requirement was that the string be no less than 10 characters in length and no more than 16 then this very simple validation will at least provide a answer to the basic question 'Does this string fall within the defined character length?' However it doesn't really handle failure. Over time developers' will learn how to approach this properly but they will still find themselves having to take differing approaches depending on whether they are validating parameter inputs, properties or results.

Using Metalama tasks like this can be solved easily. It has a patterns library that itself has a number of pre-made contracts for a wide range of scenarios including the example under discussion.

You could write code as follows (using a simple console application as an example) employing no more than a simple attribute;

<br>

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

<br>

Metalama's StringLength aspect takes as parameters either a maximum, or a minimum and maximum length and in the event of a validation failure throws a System.ArgumentException.

At the point of compilation it adds the necessary logic into your code.

<br>

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

<br>

There are numerous benefits to using Metalama contracts for validation. They are named in such a way that their intention is clear and where appropriate accept parameters that provide flexibility in the rules being tested. When validation fails it does so by throwing standard exceptions that are easy to handle. The real benefit though is that they can be used in exactly the same way to validate both inputs and outputs.

In the two examples that follow the task remains the same but instead of validating a property input parameters are validated in the first example , and the actual output in the second. In both cases the code that Metalama adds at compilation is also shown.

<br>

```c#
static string CreatePasswordValidatingInputs([StringLength(5,8)]string a, [StringLength(5, 8)] string b)
{
    return  a + b;
}
```

<br>

Which at compile time becomes;

<br>

```c#
     static string CreatePasswordValidatingInputs([StringLength(5,8)]string a, [StringLength(5, 8)] string b)
     {
         if (b.Length < 5 || b.Length > 8)
         {
             throw new ArgumentException($"The  'b' parameter must be a string with length between {5} and {8}.", "b");
         }
         if (a.Length < 5 || a.Length > 8)
         {
             throw new ArgumentException($"The  'a' parameter must be a string with length between {5} and {8}.", "a");
         }
         return a + b;

     }
```

<br>

And for outputs;

<br>

```c#
 [return: StringLength(10,16)]
 static string CreatePasswordValidatingOutput(string a, string b)
 {
     return a + b;
 }
```

<br>

Which at compile time becomes;

```c#
    [return: StringLength(10,16)]
   static string CreatePasswordValidatingOutput(string a, string b)
   {
       string returnValue;
       returnValue = a + b;


       if (returnValue.Length < 10 || returnValue.Length > 16)
       {
           throw new PostconditionViolationException($"The  return value must be a string with length between {10} and {16}.");
       }
       return returnValue;

   }
```

<br>

Exactly the same contract being used in ostensibly the same way via an attribute for three quite different validation scenarios but producing consistent code at compile time that the developer has not had to write by hand.

> <b>Whilst it should be pointed out that there is a StringLength attribute that forms part of the system.ComponentModel.DataAnnotations library it does not offer the same versatility oas that provide by Metalama.Patterns.Contracts in as much as it cannot be applied to return values and there is a necessity for the developer to provide their own error message.</b>

<br>

If you'd like to know more about Metalama in general then visit our [website](https://www.postsharp.net/metalama).

You can learn more about Metalama contracts [here](https://doc.postsharp.net/metalama/patterns/contracts).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
