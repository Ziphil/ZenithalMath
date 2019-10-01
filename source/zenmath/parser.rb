# coding: utf-8


require 'pp'
require 'rexml/document'
include REXML


module ZenithalMathParserMethod

  include ZenithalMathCreater
  include ZenithalParserMethod

  private

  def parse_element
    parser = Parser.build(self) do
      start_char = +parse_char_any([ELEMENT_START, MACRO_START])
      name = +parse_identifier
      marks = +parse_marks
      attributes = +parse_attributes.maybe || {}
      math_macro = start_char == MACRO_START && @math_macro_names.include?(name)
      if math_macro
        @math_level += 1
      end
      children_list = +parse_children_list(marks.include?(:verbal))
      if math_macro
        @math_level -= 1
      end
      if name == SYSTEM_INSTRUCTION_NAME
        +parse_space
      end
      if start_char == MACRO_START
        marks.push(:macro)
      end
      if math_macro
        next process_math_macro(name, attributes, children_list)
      elsif @math_level > 0
        next create_math_elements(name, attributes, children_list)
      else
        next create_nodes(name, marks, attributes, children_list)
      end
    end
    return parser
  end

  def parse_special_element(kind)
    parser = Parser.build(self) do
      unless @math_level > 0 || @special_element_names[kind]
        +parse_none
      end
      +parse_char(SPECIAL_ELEMENT_STARTS[kind])
      children = +parse_nodes(false)
      +parse_char(SPECIAL_ELEMENT_ENDS[kind])
      if @math_level > 0
        next create_math_elements("row", {}, [children])
      else
        next create_nodes(@special_element_names[kind], [], {}, [children])
      end
    end
    return parser
  end

  def parse_text(verbal)
    parser = Parser.build(self) do
      texts = +(parse_text_plain(verbal) | parse_escape).many(1)
      if @math_level > 0
        next create_math_text(texts.join)
      else
        next Text.new(texts.join, true, nil, false)
      end
    end
    return parser
  end

  def process_math_macro(name, attributes, children_list)
    elements = Nodes[]
    if @macros.key?(name)
      next_children_list = children_list.map do |children|
        element = Element.build("math") do |element|
          element["xmlns"] = "http://www.w3.org/1998/Math/MathML"
          element << children
        end
        next element
      end
      raw_elements = @macros[name].call(attributes, next_children_list)
      raw_elements.each do |raw_element|
        elements << raw_element
      end
    else
      throw(:error, error_message("No such macro"))
    end
    return elements
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