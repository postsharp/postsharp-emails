# Common Tasks: Memoization, A Simplified Form of Caching

Developers understand that implementing caching can significantly improve the performance of their applications. However, the performance gain needs to be offset against the costs of implementing it, even when doing so with Metalama.

There is an alternative. As expected, Metalama supports it and simplifies its implementation to merely adding an attribute to your code. That alternative is Memoization.

The table below highlights the primary differences between Memoization and caching.

| Factor                             | Memoization                                                  | Caching                                                                                                             |
| ---------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| <b>Scope</b>                       | Local to a single class instance within the current process. | Either local or shared, when run as an external service such as Redis.                                              |
| <b>Uniqueness of cache items</b>   | Specific to the current instance or type.                    | Based on explicit string cache keys.                                                                                |
| <b>Complexity and Overhead</b>     | Minimal overhead.                                            | Significant overhead related to the generation of cache keys and in the case of distributed caching, serialization. |
| <b>Expiration and Invalidation</b> | No expiration or invalidation.                               | Advanced and configurable expiration policies and invalidation APIs.                                                |

From this comparison, it's clear that in very simple cases, Memoization is the obvious choice to implement a simplified form of caching.

However, some caveats apply to the current implementation of Memoization:

- It can currently only be applied to get-only properties or parameterless methods.
- There is no guarantee that a method will only be called once, although it will always return the same value or object.
- Additional memory allocation overhead may occur.

Using Memoization with Metalama requires adding the `Metalama.Patterns.Memoization` library to your project and applying the `[Memoize]` attribute where necessary. An example is shown below.

```c#
using Metalama.Patterns.Memoization;
using System;
using System.IO.Hashing;

namespace CommonTasks.Memoize
{
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
}
```

This code, at compile time, becomes:

```c#
using Metalama.Patterns.Memoization;
using System;
using System.IO.Hashing;
using System.Runtime.CompilerServices;

namespace CommonTasks.Memoize
{
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
                    global::System.Threading.Interlocked.CompareExchange(ref this._Hash, value, null);
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
                global::System.Threading.Interlocked.CompareExchange(ref this._ToString, value, null);
            }

            return _ToString;
        }

        private StrongBox<ReadOnlyMemory<byte>> _Hash;
        private string _ToString;
    }
}
```

As you can see, this is a much simpler caching implementation, which may be all that is required in relatively simple scenarios.
