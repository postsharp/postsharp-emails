---
subject: "Auto-Retry Aspect with Aspect Parameters"
---

Today, we will explore how to make your aspect parametric and apply this technique to a new aspect type: auto-retry.

It's not uncommon for a method to fail, not due to inherent issues with the method's code, but because of unpredictable external circumstances. A common example is when connecting to an external data source or API. Instead of allowing the method to fail and immediately throw an exception that requires handling, it might be more appropriate to retry the operation.

With this in mind, let's outline some basic functionalities this aspect should have:

- If an error occurs outside the direct control of the method, the aspect should attempt to retry the operation.
- It should be possible to specify the number of retry attempts.
- Ideally, there should be a delay between each attempt to allow the external fault to correct itself (e.g., an intermittent internet connection). This delay should be configurable.

We want our _retry_ aspect to accept two parameters: the maximum number of attempts and the delay between attempts.

{. note }
Because aspects add code at compile time, you can only set input parameters ahead of compilation. End users of an application will not be able to modify these.

The aspect will only apply to methods, so we already know what its main signature will look like:

```c#
public class RetryAttribute : OverrideMethodAspect
{
    public override dynamic? OverrideMethod()
    {
        throw new NotImplementedException();
    }
}
```

Since it needs to accept parameters, it will require a constructor to take them and a place to store them:

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
    public int MillisecondsOfDelay { get; set; }
}
```

Now we can flesh out the functionality of the aspect:

```c#
/// <summary>
/// Retries the task at hand by the number of times specified in the attempts parameter. 
/// For each attempt, the delay in milliseconds is doubled.
/// </summary>
public class RetryAttribute : OverrideMethodAspect
{
    /// <summary>
    /// Constructor.
    /// </summary>
    /// <param name="attempts">
    /// The maximum number of times the method should be executed.
    /// </param>
    /// <param name="millisecondsOfDelay">
    /// The delay, in milliseconds, to wait between the first and second attempts. 
    /// The delay is doubled for each subsequent attempt.
    /// </param>
    public RetryAttribute(int attempts = 3, int millisecondsOfDelay = 1000)
    {
        this.Attempts = attempts;
        this.MillisecondsOfDelay = millisecondsOfDelay;
    }

    public override dynamic? OverrideMethod()
    {
        for (var i = 0; ; i++)
        {
            try
            {
                return meta.Proceed();
            }
            catch (Exception e) when (i < this.Attempts)
            {
                var delay = this.MillisecondsOfDelay * Math.Pow(2, i + 1);
                Console.WriteLine($"{e.Message} Waiting {delay} ms.");
                Thread.Sleep((int)delay);
            }
        }
    }

    /// <summary>
    /// The maximum number of times the method should be executed.
    /// </summary>
    public int Attempts { get; set; }

    /// <summary>
    /// The delay, in milliseconds, to wait between the first and second attempts. 
    /// The delay is doubled for each subsequent attempt.
    /// </summary>
    public int MillisecondsOfDelay { get; set; }
}
```

In the above example, we add a delay (doubled with each failure) each time the task fails. For tasks like connecting to an API with intermittent internet issues, the additional delay provides time for the connection to be restored and the method to succeed.

For example, the following method:

```c#
private static int attempts;

[Retry(5, 100)]
static bool ConnectToApi(string key)
{
    attempts++;

    Console.WriteLine($"Connecting... attempt #{attempts}.");

    if (attempts <= 4)
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

[Retry(5, 100)]
static bool ConnectToApi(string key)
{
    for (var i = 0; ; i++)
    {
        try
        {
            attempts++;

            Console.WriteLine($"Connecting... attempt #{attempts}.");

            if (attempts <= 4)
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

Notice how the aspect hard-codes the attribute's parameter inputs into the final compiled code.

This is a relatively simple example, but it illustrates how custom aspects can perform complex tasks. Here's the result when run:

```
Connecting... attempt #1.
Operation is not valid due to the current state of the object. Waiting 200 ms.
Connecting... attempt #2.
Operation is not valid due to the current state of the object. Waiting 400 ms.
Connecting... attempt #3.
Operation is not valid due to the current state of the object. Waiting 800 ms.
Connecting... attempt #4.
Operation is not valid due to the current state of the object. Waiting 1600 ms.
Connecting... attempt #5.
Success, Connected
```

The Metalama Documentation provides a wealth of information on [creating custom aspects](https://doc.metalama.net/conceptual/aspects).
