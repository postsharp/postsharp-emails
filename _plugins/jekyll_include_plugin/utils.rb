module JekyllIncludePlugin
  module Utils
    def debug(msg)
      Jekyll.logger.debug("[jekyll_include_plugin] DEBUG:", msg)
    end

    def info(msg)
      Jekyll.logger.info("[jekyll_include_plugin] INFO:", msg)
    end

    def abort(msg)
      Jekyll.logger.abort_with("[jekyll_include_plugin] FATAL:", msg)
    end

    def error(msg, context)
      page = context.registers[:page];
      Jekyll.logger.error("[jekyll_include_plugin] ERROR:", "#{msg} in #{page['path']}")
      return "ERROR: #{msg} in #{page['path']}"
    end
  end

  module GitHubUtils
    def convert_github_url_to_raw(url)
      # Check if the URL is a GitHub URL
      if url.start_with?('https://github.com/')
        # Replace 'https://github.com/' with 'https://raw.githubusercontent.com/'
        # Change 'tree/main/' to 'main/'
        url.sub('https://github.com/', 'https://raw.githubusercontent.com/')
                  .sub('/tree/', '/')
      else
        # Return the original URL if it's not a GitHub URL
        url
      end
    end
  end

  module TextUtils
    include Utils

    def pick_snippet(text, snippet_name, context)
      snippet_content = ""
      snippet_start_found = false
      snippet_end_found = false
      text.each_line do |line|
        if %r!\[<snippet\s+#{snippet_name}>\]!.match?(line)
          if snippet_start_found
            return error("Snippet '#{snippet_name}' occured twice. Each snippet should have a unique name, same name not allowed.", context)
          end
          snippet_start_found = true
          debug("Snippet '#{snippet_name}' start matched by line: #{line}")
        elsif %r!\[<endsnippet\s+#{snippet_name}>\]!.match?(line)
          snippet_end_found = true
          debug("Snippet '#{snippet_name}' end matched by line: #{line}")
          break
        elsif %r!\[<(end)?snippet\s+[^>]+>\]!.match?(line)
          debug("Skipping line with non-relevant (end)snippet: #{line}")
          next
        elsif snippet_start_found
          snippet_content += line
        end

      
      end
      
      unless snippet_start_found
        return error( "Snippet '#{snippet_name}' has not been found in '#{@params["abs_file_url"]}#{@params["rel_file_url"]}'.", context)
      end
      
      unless snippet_end_found
        return error("End of the snippet '#{snippet_name}' has not been found.", context)
      end
      
      if snippet_content.empty?
        return error("Snippet '#{snippet_name}' appears to be empty. Fix and retry.", context)
      end

      
      first_line_indent = %r!^\s*!.match(snippet_content)[0]
      return "#{first_line_indent}\n#{snippet_content}"
    end

    def remove_all_snippets(text)
      result_text = ""
      text.each_line do |line|
        if %r!\[<(end)?snippet\s+[^>]+>\]!.match?(line)
          debug("Skipping line with non-relevant (end)snippet: #{line}")
          next
        else
          result_text += line
        end
      end

      return result_text
    end

    def render_comments(text, lang)
      rendered_file_contents = ""
      text.each_line do |line|
        if %r!\[<#{lang}>\]!.match?(line)
          debug("Matched doc line: #{line}")
          rendered_file_contents += line.sub(/\[<#{lang}>\]\s*/, "")
        elsif %r!\[<\w+>\]!.match?(line)
          debug("Found non-matching doc line, skipping: #{line}")
          next
        else
          rendered_file_contents += line
        end
      end

      return rendered_file_contents
    end

    def remove_excessive_indentation(text)
      unindented_text = ""

      lowest_indent = nil
      text.each_line do |line|
        if %r!^\s*$!.match?(line)
          next
        else
          cur_indent = %r!^\s*!.match(line)[0].length
          lowest_indent = cur_indent if lowest_indent.nil? || lowest_indent > cur_indent
        end
      end
      return text if lowest_indent.nil?

      text.each_line do |line|
        if blank_line?(line)
          unindented_text += line
        else
          unindented_text += line[lowest_indent..-1]
        end
      end

      return unindented_text
    end

    def wrap_in_codeblock(text, syntax)
      return "```#{syntax}\n#{text}\n```"
    end

    def blank_line?(line)
      return %r!^\s*$!.match?(line)
    end

    def remove_any_bom(input_string)
      # Define the possible BOMs
      boms = {
        'UTF-8' => "\xEF\xBB\xBF",
        'UTF-16BE' => "\xFE\xFF",
        'UTF-16LE' => "\xFF\xFE",
        'UTF-32BE' => "\x00\x00\xFE\xFF",
        'UTF-32LE' => "\xFF\xFE\x00\x00"
      }
    
      # Check if the input string starts with any BOM and remove it
      boms.each_value do |bom|
        if input_string.start_with?(bom)
          input_string = input_string[bom.length..-1]
          break
        end
      end
    
      # Return the cleaned string
      input_string
    end

    def remove_header(text)
     
      text = remove_any_bom( text )
      filtered_text = ""
      # Variable to track if the previous line was removed
      prev_removed = false
    
      # Iterate over each line in the input text
      text.each_line do |line|
        stripped_line = line.strip
        if stripped_line.start_with?('// Copyright') || %r!^using [\w.]+;!.match?(stripped_line) || %r!^namespace [\w.]+;!.match?(stripped_line) || stripped_line.start_with?('#')
          prev_removed = true
        elsif prev_removed && line.strip.empty?
          # remove this one too.
        else
          filtered_text += line
          prev_removed = false
        end
      end
    
      return filtered_text
    end
  end
end
