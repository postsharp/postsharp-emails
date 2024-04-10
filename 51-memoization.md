# Memoization, A Simplifer and Faster Form of Caching

In a previous example, we saw how to use the `Metalama.Patterns.Caching.Aspects` to cache the return value of methods as a function of their arguments. This approach to caching is based on the generation of a unique `string`: the cache key. This approach is highly useful to make slow methods fast. However, it is not fast enough to make fast methods even faster. 

There is an alternative. As expected, Metalama supports it and simplifies its implementation to merely adding an attribute to your code. That alternative is _memoization_. Memoization is available for read-only properties or parameterless methods.

## Caching or memoization: how to choose?

The table below highlights the primary differences between memoization and caching.

| Factor                             | Memoization                                                  | Caching                                                                                                             |
| ---------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| <b>Scope</b>                       | Local to a single class instance within the current process. | Either local or shared, when run as an external service such as Redis.                                              |
| <b>Method parameters</b>                       | No supported. | Supported |
| <b>Complexity and Overhead</b>     | Minimal overhead.                                            | Significant overhead related to the generation of cache keys and in the case of distributed caching, serialization. |
| <b>Expiration and Invalidation</b> | Not supported.                               | Advanced and configurable expiration policies and invalidation APIs.                                                |

From this comparison, it's clear that in very simple cases, memoization is the obvious choice to implement a simplified form of caching. 

## Example

Using Memoization with Metalama requires adding the `Metalama.Patterns.Memoization` library to your project and applying the `[Memoize]` attribute where necessary.  Let's consider an example where the challenge is to make sure that the `Hash` property and `ToString()` method (supposedly called at a very high frequency) only do their computation and allocate memory once.


```c#
public class HashedBuffer
{
    public HashedBuffer( ReadOnlyMemory<byte> buffer )
    {
        this.Buffer = buffer;
    }

    public ReadOnlyMemory<byte> Buffer { get; }

    [Memoize]
    public ReadOnlyMemory<byte> Hash => XxHash64.Hash( this.Buffer.Span );

    [Memoize]
    public override string ToString() => $"{{HashedBuffer ({this.Buffer.Length} bytes)}}";
}
```

This code, at compile time, becomes:

```c#
public class HashedBuffer
{
    public HashedBuffer(ReadOnlyMemory<byte> buffer)
    {
        this.Buffer = buffer;
    }

    public ReadOnlyMemory<byte> Buffer { get; }

    [Memoize]
    public ReadOnlyMemory<byte> Hash
    {
        get
        {
            if (this._Hash == null)
            {
                var value = new StrongBox<ReadOnlyMemory<byte>>(this.Hash_Source);
                Interlocked.CompareExchange(ref this._Hash, value, null);
            }

            return _Hash!.Value;
        }
    }

    private ReadOnlyMemory<byte> Hash_Source => XxHash64.Hash(this.Buffer.Span);

    [Memoize]
    public override string ToString()
    {
        if (this._ToString == null)
        {
            string value;
            value = $"{{HashedBuffer ({this.Buffer.Length} bytes)}}";
            Interlocked.CompareExchange(ref this._ToString, value, null);
        }

        return _ToString;
    }

    private StrongBox<ReadOnlyMemory<byte>> _Hash;
    private string _ToString;
}

```

As you can see, this is a much simpler caching implementation, which may be all that is required in relatively simple scenarios.

## Summary

Memomization is one of the simplest way to make CPU-intensive applications faster without adding boilerplate code. It is even simpler and allocates less memory than using the `Lazy<T>` class.