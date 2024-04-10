# Did You Install Visual Tools for Metalama?

If you are using Visual Studio 2022 (any edition), ensure that you have installed the [Visual Tools for Metalama and PostSharp](https://marketplace.visualstudio.com/items?itemName=PostSharpTechnologies.PostSharp). Although not a prerequisite for using Metalama, it significantly simplifies the process by offering several useful features in the IDE.

Primarily, it allows you to visualize how Metalama will impact your code.

![](images/vsx2.gif)

The right-click context menu in the editor window provides the 'Show Metalama Diff' option. This command opens a separate editor window, displaying the precise locations and modifications that Metalama will make at compile time.

For new Metalama users, this feature is incredibly helpful as it reveals exactly how your code will be transformed at compile time. It also ensures that the functionality you want Metalama to add to your code is indeed being incorporated.

As you start crafting your custom Metalama aspects, this feature becomes even more advantageous, allowing you to see how your aspects are integrated into your codebase.

The Metalama extension also includes an aspect viewer, which offers a comprehensive overview of your project and its interaction with Metalama. You can access the viewer through the extensions menu.

![](images/aspectViewer.png)

The aspect viewer comprises three panes.

![](images/aspectViewer1.png)

The top pane displays all the aspects that are <b>available</b> to the project. This allows you to see all potential aspects and serves as a straightforward way to explore the available aspects within Metalama libraries (such as the Metalama.Patterns.Contracts library) without needing to consult the documentation.

In the central pane, you can identify which parts of your project's code are influenced by aspects. To use this pane, you must first select the aspect of interest in the upper pane.

> <b>Note: If you apply aspects to the return value of methods, they will not appear in the Affected Code pane.</b>

Another useful feature of this extension is its seamless integration with Visual Studio's code lens feature.

In the brief clip below, you'll see a class implementing an interface where Metalama aspects have been applied to some properties. While it's not immediately clear that the aspects have been inherited, a closer look reveals that the code lens feature confirms this. The 'Show Metalama Diff' command further corroborates it.

![](images/vsx3.gif)

![](images/us1.jpg)

This tool also offers syntax highlighting for specific Metalama keywords, which is especially beneficial when creating your custom aspects.

> Currently, there are no similar equivalents of this tool for either VSCode or JetBrains' Rider IDE.

The Metalama Tools for Visual Studio 2022 extension is available at no cost. New Metalama users will find this tool insightful, as it demonstrates what Metalama does precisely. It shows the amount of standard boilerplate code it writes on your behalf, saving you time and preserving the clarity of your codebase.

Experienced Metalama users will appreciate both the syntax highlighting and the ability to see how their custom aspects are likely to interact with other third-party code.

