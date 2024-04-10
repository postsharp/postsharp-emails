# Memoization: A Simplified and Faster Form of Caching

In a previous example, we explored the use of `Metalama.Patterns.Caching.Aspects` to cache the return value of methods as a function of their arguments. This caching approach is based on the generation of a unique `string`: the cache key. While this method is highly effective in accelerating slow methods, it might not be as efficient for speeding up already fast methods.

Fortunately, Metalama provides an alternative: _memoization_. The implementation of memoization is simplified to the addition of an attribute to your code. Memoization is available for read-only properties or parameterless methods.

## Caching or Memoization: How to Choose?

The table below delineates the primary differences between memoization and caching.

| Factor                             | Memoization                                                  | Caching                                                                                                             |
| ---------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| <b>Scope</b>                       | Local to a single class instance within the current process. | Either local or shared, when run as an external service such as Redis.                                              |
| <b>Method Parameters</b>                       | Not supported. | Supported |
| <b>Complexity and Overhead</b>     | Minimal overhead.                                            | Significant overhead related to the generation of cache keys and in the case of distributed caching, serialization. |
| <b>Expiration and Invalidation</b> | Not supported.                               | Advanced and configurable expiration policies and invalidation APIs.                                                |

From this comparison, it's clear that memoization is the preferable choice for very simple cases, providing a simplified form of caching.

## Example

To use Memoization with Metalama, add the `Metalama.Patterns.Memoization` library to your project and apply the `[Memoize]` attribute where necessary.  Let's consider an example where the challenge is to ensure that the `Hash` property and `ToString()` method (presumably called at a very high frequency) only perform their computation and allocate memory once.

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

At compile time, this code becomes:

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

Memoization is one of the simplest ways to accelerate CPU-intensive applications without adding boilerplate code. It is even simpler and allocates less memory than using the `Lazy<T>` class.
