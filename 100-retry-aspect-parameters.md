# Creating Custom Aspects: Adding Input Parameters

There may be times when you want to specify certain parameters to dictate how an aspect behaves. This simple example will demonstrate an aspect that can add basic exception handling to a method.

It's not unusual for a method to fail, not because of any inherent issues with the method's code, but due to unpredictable external circumstances. A good example of this is when connecting to an external data source or API. Instead of letting the method fail and immediately throw an exception that needs handling, it might be more appropriate to retry the operation.

With this in mind, let's outline some basic functionalities this aspect should have:

- If an error occurs outside the direct control of the method, the aspect should attempt to retry the operation.
- It should be possible to specify the number of attempts the aspect should make.
- Ideally, there should be a delay between each attempt to allow the external fault to correct itself (e.g., an intermittent internet connection), and this delay should be configurable.

> <b>NB: Because aspects add code at compile time, you can only set input parameters ahead of compilation. End users of an application will not be able to set these.</b>

The aspect will only apply to methods, so we already know what its main signature will be:

```c#
public class RetryAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        throw new NotImplementedException();
    }
}
```

Since it needs to accept parameters, it will require a constructor that takes them and a place to store them:

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

Now we can flesh out the functionality of the aspect:

```c#
 /// <summary>
 /// Retries the task at hand by the number of times stipulated as attempts. For each attempt, the number of
 /// milliseconds of Delay is doubled.
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
     /// Gets or sets the delay, in ms, to wait between the first and the second attempt. The delay is doubled at
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
     /// Gets or sets the delay, in ms, to wait between the first and the second attempt. The delay is doubled at
     /// every further attempt.
     /// </summary>
     public int MillisecondsOfDelay { get; set;}


 }
```

In the above example, we are essentially adding a delay (doubled with each failure) each time the task fails. If this were for a task that connected to an API and there was an intermittent internet connection, the additional delay would provide time for the connection to be restored and the method to succeed.

In use, the following method:

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
     Console.WriteLine("Success, Connected");
     return true;
 }

```

Is converted at compile time to:

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

Notice how the aspect has hard-coded the attribute's parameter inputs into the final compiled code.

This is a relatively contrived example, but it serves to illustrate that custom aspects you create can perform very complex tasks. Here's the result when run:

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

The Metalama Documentation provides a wealth of information on [creating custom aspects](https://doc.postsharp.net/metalama/conceptual/aspects).


If you're interested in learning more about Metalama, visit our [website](https://www.postsharp.net/metalama).

Join us on [Slack](https://www.postsharp.net/slack) to stay updated on what's new and get answers to any technical questions you might have.
