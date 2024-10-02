# Validate Naming Conventions with Metalama

Hi {{firstName}},

In my previous email I briefly showed how you can use Metalama to generate code. Today, I would like to introduce Metalama’s second pillar: code verification.

You’ve perhaps experienced how hard it can be to align everyone on the same naming conventions. With Metalama, you define rules and conventions using plain C#. They will be enforced both in real-time in the IDE and at compile time.

For instance, assume you want every class implementing IInvoiceFactory to have the InvoiceFactory suffix. You can do this with a single attribute.

```csharp
[DerivedTypesMustRespectNamingConvention( "*InvoiceFactory" )]
public interface IInvoiceFactory
{
Invoice CreateFromOrder( Order order );
}
```

If someone violates this rule, a warning will immediately be reported:

```
LAMA0903. The type ‘MyInvoiceConverted’ does not respect the naming convention set on the base class or interface ‘IInvoiceFactory’. The type name should match the "\*InvoiceFactory" pattern.
```

The shorter the feedback loop is, the smoother the code reviews will go! Not talking about the frustration both sides avoided!

You can learn more about code validation with Metalama in our [online documentation](https://doc.postsharp.net/metalama/examples?mtm_campaign=awareness&mtm_source=instantly).

As I wrote in my first email, our development team is looking forward to your feedback and questions on our [Slack community workspace](https://www.postsharp.net/slack?mtm_campaign=awareness&mtm_source=instantly). Of course, you can also answer this email and I’ll make sure it will reach an engineer.

Thank you!

All the best,
**{{sendingAccountFirstName}}**
Community Manager

_P.S. We will send you 3 more emails about Metalama and then stop. You can unsubscribe at any time._

