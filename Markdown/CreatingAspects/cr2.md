# Creating Aspects: Adding Aspect Parameters

There will be occasions when it would be useful to be able to specify certain parameters to determine how an aspect will behave. This simple example will show an aspect that could be used to add some basic exception handling to a method.

It's not uncommon to have situations where a method might fail but not because there is something fundamentally wrong with the code in the method but because of unpredictable external circumstances. A good example might be connecting with an external data source or api. Rather than just having the method fail and immediately throwing some sort of exception that needs to be handled it might well be appropriate to have another go.

With that in mind let's define some simple things this aspect should do.

- In the event of an error occurring outside the direct control of the method itself an attempt should be made to try again.
- It should be possible to specify how many attempts the aspect should make.
- It would be nice to add a simple delay between each attempt to allow the external fault to correct itself (ie an intermittent internet connection) and that delay should be able to be set as well.

> <b>NB Because aspects add code at compile time it is only possible to have input parameters that can be set in advance of compilation. End users of an application will not be able to set these.</b>

The aspect is going to apply to methods only so we can already determine what its main signature will be.

```c#
public class RetryAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        throw new NotImplementedException();
    }
}
```

As it needs to accept parameters it is going to require a constructor that accepts them and something in which to store them.

```c#
public class RetryAttribute : OverrideMethodAspect
{

    public RetryAttribute(int attempts, int millisecondsOfDelay)
    {
        this.Attempts = attempts;
        this.MillisecondsOfDelay = millisecondsOfDelay;
    }

    public override dynamic? OverrideMethod() { throw new NotImplementedException(); }

    public int Attempts { get; set; }

    public int MillisecondsOfDelay { get; set;}
}
```

Now the functionality of the aspect can be fleshed out.

```c#
 /// <summary>
 /// Retries the task at hand by the number of times stipulated as attempts. For each attemt the number of
 /// milliseconds of Delay is doubled up.
 /// </summary>
 ///
 /// <remarks></remarks>
 ///
 /// <seealso cref="T:OverrideMethodAspect"/>

 public class RetryAttribute : OverrideMethodAspect
 {

     /// <summary>
     /// Constructor.
     /// </summary>
     ///
     /// <remarks></remarks>
     ///
     /// <param name="attempts">
     /// Gets or sets the maximum number of times that the method should be executed.
     /// </param>
     /// <param name="millisecondsOfDelay">
     /// Gets or set the delay, in ms, to wait between the first and the second attempt. The delay is doubled at
     /// every further attempt.
     /// </param>

     public RetryAttribute(int attempts, int millisecondsOfDelay)
     {
         this.Attempts = attempts;
         this.MillisecondsOfDelay = millisecondsOfDelay;
     }


     public override dynamic? OverrideMethod()
     {
         for(var i = 0; ; i++)
         {
             try
             {
                 return meta.Proceed();
             } catch(Exception e) when (i < this.Attempts)
             {
                 var delay = this.MillisecondsOfDelay * Math.Pow(2, i + 1);
                 Console.WriteLine($"{e.Message} Waiting {delay} ms.");
                 Thread.Sleep((int)delay);
             }
         }
     }


     /// <summary>
     /// Gets or sets the maximum number of times that the method should be executed.
     /// </summary>
     public int Attempts { get; set; }

     /// <summary>
     /// Gets or set the delay, in ms, to wait between the first and the second attempt. The delay is doubled at
     /// every further attempt.
     /// </summary>
     //public double Delay { get; set; }

     public int MillisecondsOfDelay { get; set;}


 }
```

In the example above we are essentially adding a delay of the figure we set in milliseconds (doubled up each time) each time the task fails. That way if this was for a task that connected to an api and there was an intermittent internet connection the additional delay would provide time for it to come back up and the method succeed.

In use the following method,

```c#
private static int attempts;
private static string suffix;

 [Retry(5, 100)]
 static bool ConnectToApi(string key)
 {
     attempts++;
     switch(attempts)
     {
         case 1:
             suffix = "st";
             break;
         case 2:
             suffix = "nd";
             break;
         case 3:
             suffix = "rd";
             break;
         case 4:
             suffix = "th";
             break;
     }
     Console.WriteLine($"Connecting for the {attempts}{suffix} time.");
     if(attempts <= 4)
     {
         throw new InvalidOperationException();
     }
     Console.WriteLine("Success, Conected");
     return true;
 }

```

Is converted at compile time to;

```c#
    private static int attempts;
    private static string suffix;

    [Retry(5, 100)]
    static bool ConnectToApi(string key)
    {
        for (var i = 0; ; i++)
        {
            try
            {
                attempts++;
        switch(attempts)
        {
            case 1:
                suffix = "st";
                break;
            case 2:
                suffix = "nd";
                break;
            case 3:
                suffix = "rd";
                break;
            case 4:
                suffix = "th";
                break;
        }
        Console.WriteLine($"Connecting for the {attempts}{suffix} time.");
        if(attempts <= 4)
        {
            throw new InvalidOperationException();
        }
        Console.WriteLine("Success, Connected");
        return true;

            }
            catch (Exception e) when (i < 5)
            {
                var delay = 100 * Math.Pow(2, i + 1);
                Console.WriteLine($"{e.Message} Waiting {delay} ms.");
                Thread.Sleep((int)delay);
            }
        }
    }
```

Notice how the The aspect has hard coded the parameter inputs of the attribute into the final compiled code.

This is still a relatively contrived example producing the following result when run but none the less it serves to illustrate the fact that custom aspects that you create yourself can perform some very complex tasks.

```
Connecting for the 1st time.
Operation is not valid due to the current state of the object. Waiting 200 ms.
Connecting for the 2nd time.
Operation is not valid due to the current state of the object. Waiting 400 ms.
Connecting for the 3rd time.
Operation is not valid due to the current state of the object. Waiting 800 ms.
Connecting for the 4th time.
Operation is not valid due to the current state of the object. Waiting 1600 ms.
Connecting for the 5th time.
Success, Connected
```

The Metalama Documentation has a lot of information on [creating custom aspects](https://doc.postsharp.net/metalama/conceptual/aspects).

<br>

If you'd like to know more about Metalama in general then visit our [website](https://www.postsharp.net/metalama).

Why not join us on [Slack](https://www.postsharp.net/slack) where you can keep up with what's new and get answers to any technical questions that you might have.
