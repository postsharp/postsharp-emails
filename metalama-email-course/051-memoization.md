---
subject: "Memoization: A Simplified and Faster Form of Caching"
---

In a previous example, we explored the use of `Metalama.Patterns.Caching.Aspects` to cache the return values of methods based on their arguments. This caching approach relies on generating a unique `string` as the cache key. While effective for accelerating slow methods, it may not be as efficient for speeding up already fast methods.

Fortunately, Metalama provides an alternative: _memoization_. Memoization is available for read-only properties or parameterless methods. It does not rely on generating a cache key, nor does it use an in-memory synchronized dictionary or out-of-process storage. Instead, it stores the cached value directly within the current object, offering almost instant access with no per-access memory allocation.

## Caching or Memoization: How to Choose?

The table below highlights the key differences between memoization and caching:

| Factor                             | Memoization                                                  | Caching                                                                                                             |
| ---------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| <b>Scope</b>                       | Local to a single class instance within the current process. | Can be local or shared, such as when using an external service like Redis.                                          |
| <b>Method Parameters</b>           | Not supported.                                               | Supported.                                                                                                         |
| <b>Complexity and Overhead</b>     | Minimal overhead.                                            | Significant overhead due to cache key generation and, in the case of distributed caching, serialization.            |
| <b>Expiration and Invalidation</b> | Not supported.                                               | Offers advanced and configurable expiration policies and invalidation APIs.                                         |

From this comparison, it is clear that memoization is the better choice for simple scenarios, providing a lightweight form of caching.

## Example

To use memoization with Metalama, add the `Metalama.Patterns.Memoization` library to your project and apply the `[Memoize]` attribute where needed. Consider the following example, where the goal is to ensure that the `Hash` property and `ToString()` method (which are called very frequently) perform their computations and allocate memory only once.

```c#
public class HashedBuffer
{
    public HashedBuffer(ReadOnlyMemory<byte> buffer)
    {
        this.Buffer = buffer;
    }

    public ReadOnlyMemory<byte> Buffer { get; }

    [Memoize]
    public ReadOnlyMemory<byte> Hash => XxHash64.Hash(this.Buffer.Span);

    [Memoize]
    public override string ToString() => $"HashedBuffer ({this.Buffer.Length} bytes)";
}
```

At compile time, this code is transformed into:

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
            value = $"HashedBuffer ({this.Buffer.Length} bytes)";
            Interlocked.CompareExchange(ref this._ToString, value, null);
        }

        return _ToString;
    }

    private StrongBox<ReadOnlyMemory<byte>> _Hash;
    private string _ToString;
}
```

As shown, this is a much simpler caching implementation, which may be sufficient for relatively straightforward scenarios.

## Summary

Memoization is one of the simplest ways to accelerate CPU-intensive applications without adding boilerplate code. It is even simpler and uses less memory than the `Lazy<T>` class.
