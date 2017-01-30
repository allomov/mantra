require "redcarpet"

class TestExampleRender < Redcarpet::Render::Base
  attr_accessor :command
  attr_accessor :output

  def files
    @files ||= {}
  end

  def block_code(code, language)
    return if code.empty?
    if language.start_with?("file:")
      files[language[5..-1]] = code
    elsif self.respond_to?(:"#{language}=")
      self.send(:"#{language}=", code)
    else
      puts "Warning: don't know what to do with the following language: #{language}"
    end
  end

  def codespan(code)
    language = code.lines.first
    block_code(code[language.size..-1], language.strip)
  end
end

def markdown_example_processor(file)
  processor = TestExampleRender.new
  markdown = Redcarpet::Markdown.new(processor)
  text = File.read(file)
  markdown.render(text)
  processor
end
