# coding: utf-8


require 'pp'
require 'rexml/document'
include REXML


module ZenithalMathCreater

  CREATION_METHODS = {
    "sup" => :sup, "sub" => :sup,
    "row" => :row
  }

  private

  def create_math_elements(name, attributes, children_list)
    nodes = Nodes[]
    CREATION_METHODS.each do |match_name, method_name|
      if name == match_name
        nodes = send("create_#{method_name}", name, attributes, children_list)
        break
      end
    end
    return nodes
  end

  def create_math_text(text)
    this = Nodes[]
    text.each_char do |char|
      if char =~ /\d/
        this << Element.build("mn") do |this|
          this << ~char
        end
      elsif char =~ /\w/
        this << Element.build("mi") do |this|
          this << ~char
        end
      elsif char !~ /\s/
        this << Element.build("mo") do |this|
          this << ~char
        end
      end
    end
    return this
  end

  def create_sup(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("m#{name}") do |this|
      this << Element.build("mrow") do |this|
        this << children_list[0]
      end
      this << Element.build("mrow") do |this|
        this << children_list[1]
      end
    end
    return this
  end

  def create_row(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("mrow") do |this|
      this << children_list.first
    end
    return this
  end

end