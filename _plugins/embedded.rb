class EmbeddedTag < Liquid::Tag
  def initialize(tag_name, markup, tokens)
    super
    
     @attributes = {}
     markup.scan(::Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
     end
     @markup = markup
     
  end

  def render(context)
  
    id = @attributes['id']
    url = @attributes['url']
    node = @attributes['node']
  
  
    # Write the output HTML string
    
    output = "<div id=\"" + id + "\"></div>"
    output  += "<script>"
    output  += "$('#" + id + "').load('" + url + " #" + node + "', "
    output  += "    function(data) {"
    output  += "        $('#" + id + " .tabGroup').tabs();"
    output  += "    } );"
    output  += " </script> "

    # Render it on the page by returning it
    return output;
    
  end
   
end

Liquid::Template.register_tag('embedded', EmbeddedTag)