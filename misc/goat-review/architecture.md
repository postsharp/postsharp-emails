In my previous email, I demonstrated how Metalama can generate boilerplate code on-the-fly during compilation, automating the task of implementing necessary but repetitive code. However, code generation is not the only functionality Metalama offers. In this email, I will explore Metalama's second horn: its ability to validate source code against architectural rules.

## Why Does Architecture Matter?

Most non-trivial projects start with a phase where the team defines the application architecture. Software architecture is a broad concept. At the highest level, you have _solution architecture_, which defines the different applications and ways of communication. On a lower level, the _application architecture_ selects the frameworks, defines the base classes and interfaces, and designs the implementation patterns. Defining the application architecture is a creative and iterative process. While it can be done in a waterfall way using UML diagrams (and probably should in complex projects), the architecture will be refined over time during the first weeks of the project.

Once the architecture is well-understood, it's important that it's _respected_. You can understand architecture as a set of _generative rules_, i.e., rules from which artifacts are built. This, by the way, is not unique to software architecture and applies to buildings and urbanism. Code is to programmers what bricks are to masons.

Software architecture directly relates to software complexity. An important metric in software complexity is the number of rules _and exceptions_ it follows. The fewer rules and exceptions, the lower the complexity.

To take an analogy in information theory, consider a compression algorithm like Brotli or LZMA. Their whole purpose is to reduce the _predictability_ of the input stream to its minimum. The output of this algorithm is reduced to the real informational complexity of the input stream. Of course, I'm not even remotely suggesting that your code should look like Brotli-encoded. What I'm suggesting is that it should have minimal informational complexity. Because, eventually, we have to "load" this informational complexity into our brains. And, if you think your brain has unlimited capacity, be certain that the cognitive abilities of your colleagues have some limits!

To have minimal informational complexity in a codebase, and to make sure the codebase fits in your brain, you should strive not only for the lowest number of rules but also for the fewest exceptions to the rules, because both rules and exceptions count as pieces of information.

At the end of the day, codebase complexity is the ultimate metric in software engineering. We are rarely limited by hardware resources. Most of the time, the limiting factor we software engineers have to deal with is our own limited cognitive capacity, both as individuals and collectively. How many _smart enough_ developers can you hire for your budget? The lower the codebase complexity, the larger the pool you can hire from.

When code complexity is too high, productivity drops, and bugs surge.

## What is Architecture Erosion?

Most of the time, the output of the software architecture role is a set of texts and diagrams describing the rules, conventions, and patterns that we would like the codebase to follow.

Because these texts and diagrams are not provided in executable form, rule violations can happen in source code, degrading code quality. To avoid rule violations, we perform code reviews, a manual process that sometimes happens days after the code has been written. First, in an attempt to streamline the merge process, benign violations are ignored. Then, the broken window syndrome happens, and more and more violations are accepted in the codebase. Progressively, rules are no longer followed. With turnover in the team, new team members may not even be trained in the original architecture.

This process is called _architecture erosion_: the growing gap between the original architectural intention and its implementation in source code.

## How Can Metalama Help Avoid Architecture Erosion?

As we have seen, one of the principal causes of architecture erosion is the lack of automated verification of the source code against the architecture, relying instead on the long feedback loop provided (in the best cases) by code reviews.

Metalama allows you to validate your architecture both _in real-time_, straight from the IDE, and during your CI build. Therefore, the feedback loop is shortened from hours to seconds. Violations can be corrected immediately. As for the most important defects, they will generate an error and won't even pass the continuous integration build.

The [open-source](https://github.com/postsharp/Metalama.Extensions/tree/HEAD/src/Metalama.Extensions.Architecture) [Metalama.Extensions.Architecture](https://www.nuget.org/packages/Metalama.Extensions.Architecture) package offers several pre-made custom attributes and compile-time APIs that cover many common conventions teams might want to follow.

Let's see two families of rules you can easily validate with Metalama: naming conventions and component dependencies.

## Verifying Naming Conventions

_Il faut appeler une chèvre une chèvre._

You’ve perhaps experienced how hard it can be to align everyone on the same naming conventions. With Metalama, you define rules and conventions using plain C#. They will be enforced both in real-time in the IDE and at compile time.

For instance, assume you want every class implementing `ICheeseFactory` to have the `CheeseFactory` suffix. You can do this with a single attribute: [DerivedTypesMustRespectNamingConvention](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-aspects-derivedtypesmustrespectnamingconventionattribute).

```csharp
[DerivedTypesMustRespectNamingConvention( "*CheeseFactory" )]
public interface ICheeseFactory
{
    Cheese Create( string king, decimal quantity );
}
```

If someone violates this rule, a warning will immediately be reported:

```
LAMA0903. The type ‘MyInvoiceConverted’ does not respect the naming convention set on the base class or interface ‘IInvoiceFactory’. The type name should match the "\*InvoiceFactory" pattern.
```

The shorter the feedback loop is, the smoother the code reviews will go! Not to mention the frustration both sides avoided!

For details regarding naming convention enforcement, please refer to the [Metalama documentation](https://doc.postsharp.net/metalama/conceptual/architecture/naming-conventions).

## Validating Dependencies

Let's examine how to verify that components are _used_ as intended.

Let's assume we have a constructor that slightly modifies the object's behavior to make it more testable. We want to ensure that this constructor is used only in tests. Metalama provides the [CanOnlyBeUsedFrom](https://doc.postsharp.net/etalama/api/metalama-extensions-architecture-aspects-canonlybeusedfromattribute) attribute for this purpose.

```c#
public class CheeseFactory
{
    private bool isTest;

    public CheeseFactory()
    {
    }

    [CanOnlyBeUsedFrom(Namespaces = new[] {"**.Tests"})]
    public CheeseFactory(bool isTest)
    {
        // Used to trigger specific test configuration
        this.isTest = isTest;
    }
}
```

If we attempt to create a new `CheeseFactory` instance in a namespace that isn't suffixed by `Tests`, we will see a warning.

![](../metalama-email-course/images/ValidationWarning.jpg)

What's important here is that we have a way to convey the _design intent_ we had when writing a piece of code. Many defects stem from the fact that the design intent of the initial author faded away. Thanks to meta-programming, you can make this design intent explicit and verified in real time.

For details regarding usage validation, please refer to the [Metalama documentation](https://doc.postsharp.net/metalama/conceptual/architecture/usage).

## Fabrics

In the previous examples, I have used custom attributes to express architectural constraints. However, this is not always the most convenient way to express architecture.

Suppose we have a project composed of a large number of components. Each of these components is implemented in its own namespace and is made up of several classes. There are so many components that we don't want to have them each in their own project.

However, we still want to isolate components from each other. Specifically, we want `internal` members of each namespace to be visible only within this namespace. Only `public` members should be accessible outside of its home namespace.

Additionally, we want `internal` components to be accessible from any test namespace.

With Metalama, you can validate each namespace by adding a _fabric_ type: a compile-time class that executes within the compiler or the IDE.

```cs
namespace BarnEquipment
{
    internal class Fabric : NamespaceFabric
    {
        public override void AmendNamespace(INamespaceAmender amender)
        {
            amender.InternalsCanOnlyBeUsedFrom(from =>
                from.CurrentNamespace().Or(or => or.Type("**.Tests.**")));
        }
    }

    internal class Door;
}

namespace FieldEquipment
{
    // Warning: BarnEquipment.Door is internal to the `BarnEquipment` namespace.
    public class PedenstrianFriendlyGate : BarnEquipment.Door;

}
```

Now, if some foreign code tries to access an internal API of the `BarnEquipment` namespace, a warning will be reported.

The package includes verification methods like:

- [InternalsCanOnlyBeUsedFrom](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-fabrics-verifierextensions-internalscanonlybeusedfrom)
- [InternalsCannotBeUsedFrom](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-fabrics-verifierextensions-internalscannotbeusedfrom)
- [CanOnlyBeUsedFrom](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-fabrics-verifierextensions-canonlybeusedfrom)
- [CannotBeUsedFrom](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-fabrics-verifierextensions-cannotbeusedfrom)
- [MustRespectNamingConvention](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-fabrics-verifierextensions-mustrespectnamingconvention)
- [MustRespectRegexNamingConvention](https://doc.postsharp.net/metalama/api/metalama-extensions-architecture-fabrics-verifierextensions-mustrespectregexnamingconvention)

## Verifying Your Own Rules
If, like _la chèvre de Monsieur Seguin_, you feel confined within the enclosure of predefined methods and yearn for the fresh air of do-it-yourself mountains, we have good news for you. First, you can create your own rules—both custom attributes and programmatic—using Metalama's API. Second, there's no wolf in these mountains. At worst, you might get lost or a bit dazed bu the fresh air, and sheepishly find your way back to the enclosure.

There are two ways to extend the API: by creating your own _rules_ (like `InternalsCanOnlyBeUsedFrom` or `CannotBeUsedFrom`) or your own _predicates_ (like `CurrentNamespace`).

For instance, the following snippet defines a `NameEndsWith` predicate that matches members whose names end with a given suffix.

```csharp
[CompileTime]
public static class Extensions
{
    public static ReferencePredicate NameEndsWith(
        this ReferencePredicateBuilder builder,
        string suffix )
        => new NameSuffixPredicate( builder, suffix );
}

internal class NameSuffixPredicate : ReferenceEndPredicate
{
    private readonly string _suffix;

    public NameSuffixPredicate( ReferencePredicateBuilder builder, string suffix ) : base( builder )
    {
        this._suffix = suffix;
    }

    protected override ReferenceGranularity GetGranularity() => ReferenceGranularity.Member;

    public override bool IsMatch( ReferenceEnd referenceEnd )
        => referenceEnd.Member is INamedDeclaration method && method.Name.EndsWith(
            this._suffix,
            StringComparison.Ordinal );
}

```

This allows you to ensure that your code is only called by _polite_ APIs:

```csharp
internal class Fabric : ProjectFabric
{
    public override void AmendProject( IProjectAmender amender )
    {
        amender.SelectReflectionType( typeof(CofeeMachine) )
            .CanOnlyBeUsedFrom( r => r.NameEndsWith( "Politely" ) );
    }
}
```

## Conclusion

_Architecturae erosio delenda est._

Defining a well-thought-out and consistent architecture is a key phase of any non-trivial software development project. But once the architecture is defined, it shouldn't just end up in a drawer. It must be enforced.

Unless architecture rules are made executable, they can only be enforced through code reviews, which are costly, slow, and unreliable due to human factors. Code reviews driven by humans will still be important for a long time, but let's automate what can be automated.

In the previous article, I showed how Metalama can automate your repetitive code writing tasks through on-the-fly code generation. Today, I've demonstrated two ways to express architecture rules using Metalama: with custom attributes and programmatically through fabrics.

That's the end of my mini-series about Metalama. If you want to know more about Metalama, feel free to download it from NuGet or the Visual Studio Marketplace. There is a free edition to start with and tons of commented examples and ready-made, open-source implementations on the Metalama Marketplace. The development team is eager to answer your questions on our Slack workspace.

Happy meta-programming with Metalama!
