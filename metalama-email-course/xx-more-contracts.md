---
subject: "Common Tasks: Input / Output Validation"
---
# Common Tasks: Input / Output Validation

The phrase 'Garbage in, garbage out' is well-known among developers. Essentially, if the input to an application is flawed, it shouldn't be surprising if the output is also flawed. To prevent this, developers must ensure that both the input to their application's routines and the output from them meet acceptable criteria.

Validation is a task that every developer must tackle at some point. The approach they adopt often serves as a good indicator of their overall development experience.

Consider a basic requirement where a given string must fall within a certain number of characters.

A novice or relatively inexperienced developer might create a simple checking method to fulfill the immediate requirement.

```c#
bool ValidateString(string input)
{
    return input.length < 10 && input.length > 16;
}
```

If the requirement is for the string to be no less than 10 characters in length and no more than 16, then this simple validation will provide an answer to the basic question: 'Does this string fall within the defined character length?' However, it doesn't adequately handle failure. Over time, developers learn to handle this more effectively, but they still find themselves adopting different approaches depending on whether they are validating parameter inputs, properties, or results.

With Metalama, tasks like these can be solved easily. It offers a package `Metalama.Patterns.Contracts` that provides a number of pre-made contracts for a wide range of scenarios, including the example discussed here.

You could write code as follows (using a simple console application as an example), employing nothing more than a simple attribute:

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

Metalama's StringLength aspect accepts either a maximum, or a minimum and maximum length as parameters and, in the event of a validation failure, throws a System.ArgumentException.

At the point of compilation, it injects the necessary logic into your code.

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
                    throw new ArgumentException("The  'password' property must be a string with length between {10} and {16}.", "value");
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

There are numerous benefits to using Metalama contracts for validation. They are named in a way that clearly indicates their purpose, and where appropriate, they accept parameters that provide flexibility in the rules being tested. When validation fails, it does so by throwing standard exceptions that are easy to handle. The real benefit, however, is that they can be used consistently to validate both inputs and outputs.

In the two examples that follow, the task remains the same, but instead of validating a property, input parameters are validated in the first example, and the actual output in the second. In both cases, the code that Metalama adds at compilation is also shown.

```c#
static string CreatePasswordValidatingInputs([StringLength(5,8)]string a, [StringLength(5, 8)] string b)
{
    return  a + b;
}
```

Which at compile time becomes:

```c#
     static string CreatePasswordValidatingInputs([StringLength(5,8)]string a, [StringLength(5, 8)] string b)
     {
         if (b.Length < 5 || b.Length > 8)
         {
             throw new ArgumentException("The  'b' parameter must be a string with length between {5} and {8}.", "b");
         }
         if (a.Length < 5 || a.Length > 8)
         {
             throw new ArgumentException("The  'a' parameter must be a string with length between {5} and {8}.", "a");
         }
         return a + b;

     }
```

And for outputs:

```c#
 [return: StringLength(10,16)]
 static string CreatePasswordValidatingOutput(string a, string b)
 {
     return a + b;
 }
```

Which at compile time becomes:

```c#
    [return: StringLength(10,16)]
   static string CreatePasswordValidatingOutput(string a, string b)
   {
       string returnValue;
       returnValue = a + b;


       if (returnValue.Length < 10 || returnValue.Length > 16)
       {
           throw new PostconditionViolationException("The  return value must be a string with length between {10} and {16}.");
       }
       return returnValue;

   }
```

The same contract is used in ostensibly the same way via an attribute for three quite different validation scenarios but produces consistent code at compilation time that the developer has not had to write by hand.

> **Note: While the System.ComponentModel.DataAnnotations library includes a StringLength attribute, it does not offer the same versatility as that provided by Metalama.Patterns.Contracts, as it cannot be applied to return values and requires the developer to provide their own error message.**

