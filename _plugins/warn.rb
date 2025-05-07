module Jekyll
    module WarnTag
      class Tag < Liquid::Tag
        def initialize(tag_name, text, tokens)
          super
          @text = text.strip
        end
  
        def render(context)
          # Access the current file path from the context
          current_file = context.registers[:page]["path"]
  
          # Log the warning with the file path
          Jekyll.logger.warn "Liquid Warning in #{current_file}:", @text
  
          # Return an empty string to prevent rendering the tag content
          ""
        end
      end
    end
  end
  
  Liquid::Template.register_tag('warn', Jekyll::WarnTag::Tag)
  