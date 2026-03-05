This repo contains the source and images of the chains used by PostSharp Technologies.

The publishing process is the following:

- There is a GitHub action that publishes all static files to https://emails.postsharp.net/. The reason for this is to publish _images_. 
- Run Jekyll (`run-all.ps1`) to generate all HTML emails from Markdown.
- In ConvertKit:
    - Create an HTML field and paste the raw HTML. 


