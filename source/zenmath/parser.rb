# coding: utf-8


require 'pp'
require 'rexml/document'
include REXML


module ZenithalMathParserMethod

  include ZenithalMathCreater
  include ZenithalParserMethod

  private

  def determine_options(name, marks, attributes, macro, options)
    if macro && @math_macro_names.include?(name)
      options = options.clone
      options[:math] = true
      return options
    else
      return super
    end
  end

  def process_macro(name, marks, attributes, children_list, options)
    if @math_macro_names.include?(name)
      next_children_list = children_list.map do |children|
        element = Element.build("math") do |element|
          element["xmlns"] = "http://www.w3.org/1998/Math/MathML"
          element << children
        end
        next element
      end
      raw_nodes = @macros[name].call(attributes, next_children_list)
      nodes = raw_nodes.inject(Nodes[], :<<)
      return nodes
    else
      return super
    end
  end

  def create_element(name, marks, attributes, children_list, options)
    if options[:math]
      return create_math_element(name, attributes, children_list)
    else
      return super
    end
  end

  def create_special_element(kind, children, options)
    if options[:math]
      return create_math_elements("row", {}, [children])
    else
      return super
    end
  end

  def create_text(raw_text, options)
    if options[:math]
      return create_math_text(raw_text)
    else
      return super
    end
  end

end


class ZenithalMathParser < ZenithalParser

  include ZenithalMathParserMethod

  def initialize(source)
    super(source)
    @math_macro_names = []
    @math_level = 0
  end

  def register_math_macro(name, &block)
    @math_macro_names << name
    @macros.store(name, block)
  end

end