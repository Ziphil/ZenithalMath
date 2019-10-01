# coding: utf-8


require 'fileutils'
require 'open3'
require 'pp'
require 'rexml/document'
require 'zenml'
require_relative '../../source/zenmath'

include REXML
include Zenithal

Encoding.default_external = "UTF-8"
$stdout.sync = true


class WholeBookConverter

  OUTPUT_PATH = "sample/out/main.fo"
  MANUSCRIPT_DIR = "sample/manuscript"
  MACRO_DIR = "sample/macro"
  TEMPLATE_DIR = "sample/template"
  TYPESET_COMMAND = "cd sample/out & AHFCmd -pgbar -x 3 -d main.fo -p @PDF -o document.pdf -i ../converter/config.xml 2> error.txt"
  OPEN_COMMANDS = {
    :sumatra => "SumatraPDF -reuse-instance sample/out/document.pdf",
    :formatter => "AHFormatter -s -d sample/out/main.fo"
  }

  def initialize(args)
    options, rest_args = args.partition{|s| s =~ /^\-\w+$/}
    flags = Hash.new{|h, s| h[s] = nil}
    if options.include?("-t")
      flags[:typeset] = true
    end
    if options.include?("-os")
      flags[:open] = :sumatra
    end
    if options.include?("-of")
      flags[:open] = :formatter
    end
    @flags = flags
  end

  def execute
    parser = create_parser
    converter = create_converter(parser.parse)
    formatter = create_formatter
    puts("")
    save_convert(converter, formatter)
    if @flags[:typeset]
      save_typeset
    end
    if @flags[:open]
      open
    end
  end

  def save_convert(converter, formatter)
    File.open(OUTPUT_PATH, "w") do |file|
      print_progress("Convert")
      formatter.write(converter.convert, file)
    end
  end

  def save_typeset
    progress = {:format => 0, :render => 0}
    command = TYPESET_COMMAND
    stdin, stdout, stderr, thread = Open3.popen3(command)
    stdin.close
    stdout.each_char do |char|
      if char == "." || char == "-"
        type = (char == ".") ? :format : :render
        progress[type] += 1
        print_progress("Typeset", progress)
      end
    end
    thread.join
  end

  def open
    command = OPEN_COMMANDS[@flags[:open]]
    stdin, stdout, stderr, thread = Open3.popen3(command)
    stdin.close
  end

  def print_progress(type, progress = nil)
    output = ""
    output << "\e[1A\e[K"
    output << "\e[0m\e[4m"
    output << type
    output << "\e[0m : \e[36m"
    output << "%3d" % (progress&.fetch(:format, 0) || 0)
    output << "\e[0m + \e[35m"
    output << "%3d" % (progress&.fetch(:render, 0) || 0)
    output << "\e[0m"
    puts(output)
  end

  def create_parser
    source = File.read(MANUSCRIPT_DIR + "/main.zml")
    parser = ZenithalMathParser.new(source)
    parser.brace_name = "x"
    parser.bracket_name = "xn"
    parser.slash_name = "i"
    Dir.each_child(MACRO_DIR) do |entry|
      if entry.end_with?(".rb")
        binding = TOPLEVEL_BINDING
        binding.local_variable_set(:parser, parser)
        Kernel.eval(File.read(MACRO_DIR + "/" + entry), binding, entry)
      end
    end
    return parser
  end

  def create_converter(document)
    converter = ZenithalConverter.new(document)
    Dir.each_child(TEMPLATE_DIR) do |entry|
      if entry.end_with?(".rb")
        binding = TOPLEVEL_BINDING
        binding.local_variable_set(:converter, converter)
        Kernel.eval(File.read(TEMPLATE_DIR + "/" + entry), binding, entry)
      end
    end
    return converter
  end

  def create_formatter
    formatter = Formatters::Default.new
    return formatter
  end

end


whole_converter = WholeBookConverter.new(ARGV)
whole_converter.execute