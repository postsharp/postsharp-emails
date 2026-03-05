Jekyll::Hooks.register [:pages, :documents], :post_render do |page|
  images_url = page.data['images_url']
  
  # Only modify HTML output
  if page.output_ext == '.html'

    if images_url

        # Change path to images.
        page.output.gsub!(%r{(<img\s[^>]*src=["'])images([^"']*)(["'])}) do
        "#{$1}#{images_url}#{$2}#{$3}"
        end
  
    end
  end
end
