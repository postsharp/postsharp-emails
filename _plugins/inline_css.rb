require 'premailer'
require 'nokogiri'

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  if doc.output_ext == '.html'
    premailer = Premailer.new(doc.output, with_html_string: true)
    html = premailer.to_inline_css
    body_content = html[/<body\b[^>]*>(.*?)<\/body>/mi, 1] || html

    fragment = Nokogiri::HTML::DocumentFragment.parse(body_content)
    fragment.css('code').each do |code_node|
      code_node.xpath('.//text()').each do |text_node|
        content = text_node.content
        # Replace only space characters with &middot; entity, preserve other whitespace
        new_nodes = content.chars.map do |char|
          if char == ' '
            Nokogiri::XML::EntityReference.new(code_node.document, 'middot')
          else
            Nokogiri::XML::Text.new(char, code_node.document)
          end
        end
        next if new_nodes.length == 1 && new_nodes.first.text?
        new_nodes.reverse_each { |n| text_node.add_next_sibling(n) }
        text_node.remove
      end
    end

    output_html = fragment.to_html
    # Insert <br> after every </div> or </p>
    output_html.gsub!(%r{</(div|p)>}i, '</\1><br>')

    # Wrap contiguous &middot; entities with a span for color
    output_html.gsub!(/((?:&middot;)+)/) do |dots|
      %Q{<span style="color:#1a1a1a">#{dots}</span>}
    end

    doc.output = output_html
  end
end
