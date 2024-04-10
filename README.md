This repo contains the source and images of the chains used by PostSharp Technologies.

The publishing process is the following:

- There is a GitHub action that publishes all static files to https://emails.postsharp.net/. The reason for this is to publish _images_. 
- Use https://markdowntohtml.com/ to convert the Markdown file of each email to HTML. Copy the raw HTML.
- In ConvertKit:
    - Create an HTML field and paste the raw HTML. Change all images to add the `https://emails.postsharp.net/metalama-email-course` prefix before any image `src`.
    - Make sure that you're using a template with a CSS field that has the CSS of Highlight.JS.



