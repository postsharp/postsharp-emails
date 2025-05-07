# TODO: don't read the whole file into the memory from the beginning, instead process file with the parser line by line
require "open-uri"
require "liquid"
require 'active_support/all' 
require_relative "utils"

class CachedFetcher
  # Initialize a class-level instance variable for the cache
  @cache = ActiveSupport::Cache::MemoryStore.new

  # Class method to fetch data with caching
  def self.fetch(url)
    # Access the class-level instance variable using self.class
    @cache.fetch(url, expires_in: 5.minutes) do
      URI.open(url).read  # This is executed only if the cache is missed
    end
  end
end


module JekyllIncludePlugin
  class IncludeFileTag < Liquid::Tag
    include Utils
    include TextUtils
    include GitHubUtils

    def initialize(tag_name, raw_markup, tokens)
      super
      @raw_markup = raw_markup
      @params = {}
    end

    def render(context)
      parse_params(context)

      file_contents = get_raw_file_contents(context)

      if @params["snippet"]
        file_contents = pick_snippet(file_contents, @params["snippet"], context)
        file_contents = remove_excessive_indentation(file_contents)
      else
        file_contents = remove_header(file_contents)
        file_contents = remove_all_snippets(file_contents)
      end

      file_contents = file_contents.strip

      file_contents = render_comments(file_contents, context.registers[:page]["lang"])
      file_contents = add_original_indentation( file_contents )
      
      file_contents = wrap_in_codeblock(file_contents, @params["syntax"]) if @params["syntax"]

      
      return file_contents
    end

    private

    def parse_params(context)
      rendered_markup = Liquid::Template
        .parse(@raw_markup)
        .render(context)
        .gsub(%r!\\\{\\\{|\\\{\\%!, '\{\{' => "{{", '\{\%' => "{%")
        .strip
      debug("Rendered params: #{rendered_markup}")

      markup = %r!^"?(?<path>[^\s\"]+)"?(?<params>(\s+\w+="[^\"]+")*)?$!.match(rendered_markup)
      debug("Matched params: #{markup.inspect}")
      error("Can't parse include_file tag params: #{@raw_markup}", context) unless markup

      if markup[:params]
        @params = Hash[ *markup[:params].scan(%r!(?<param>[^\s="]+)(?:="(?<value>[^"]+)")?\s?!).flatten ]
      end

      if %r!^https?://\S+$!.match?(markup[:path])
        @params["abs_file_url"] = markup[:path]
      elsif %r!^file?://\S+$!.match?(markup[:path])
        @params["abs_file_url"] = markup[:path].sub(%r!^file://!, '').gsub('\\', '/')
      else
        @params["rel_file_path"] = markup[:path]
      end

      validate_param_by_regex("snippet", "^[-_.a-zA-Z0-9]+$", context)
      validate_param_by_regex("syntax", "^[-_.a-zA-Z0-9]+$", context)

      debug("Params set: #{@params.inspect}")
    end

    def validate_param_by_regex(param_name, param_regex, context)
      if @params[param_name] && ! %r!#{param_regex}!.match?(@params[param_name])
        error("Parameter '#{param_name}' with value '#{@params[param_name]}' is not valid, must match regex: #{param_regex}", context)
      end
    end

    def get_raw_file_contents(context)
      if @params["abs_file_url"]
        return get_remote_file_contents(context)
      elsif @params["rel_file_path"]
        return get_local_file_contents(context)
      end
      raise "Neither abs_file_url nor rel_file_path have been found"
    end

    def get_local_file_contents(context)
      base_source_dir = File.expand_path(context.registers[:site].config["source"]).freeze
      abs_file_path = File.join(base_source_dir, @params["rel_file_path"])

      begin
        debug("Getting contents of specified local file: #{abs_file_path}")
        return File.read(abs_file_path, **context.registers[:site].file_read_opts)
      rescue SystemCallError, IOError => e
        return error("Can't get the contents of specified local file '#{abs_file_path}' (for '#{@params["rel_file_path"]}'): #{e.message}", context)
      end
    end

    def get_remote_file_contents(context)
      begin
        url = convert_github_url_to_raw(@params["abs_file_url"])
        debug("Getting contents of specified remote file: #{url}")
    
        if url !~ /^https?:\/\//
          return URI.open(url).read
        else
          return CachedFetcher.fetch(url)
        end
      rescue => e
        return error("An error occurred while fetching the file '#{url}': #{e.message}", context)
      end
    end

    def add_original_indentation(text)
      # Determine the indentation level by checking the first non-empty line
      indentation_level = n = @params["indent"].to_i
      indentation = ' ' * indentation_level

      # Split the content into lines
      lines = text.split("\n")
      
      # Don't indent the first line, but indent subsequent lines
      lines[1..] = lines[1..].map { |line| "#{indentation}#{line}" }

      # Join the lines back together and return the result
      lines.join("\n")
    end

  end
end
