# coding: utf-8


require 'pp'
require 'rexml/document'
include REXML


module ZenithalMathCreater

  CREATION_METHODS = {
    "row" => :row,
    "sup" => :superscript, "sub" => :superscript,
    "p" => :paren, "b" => :paren, "c" => :paren, "v" => :paren, "vv" => :paren,
    "f" => :paren, "g" => :paren, "a" => :paren, "aa" => :paren
  }
  PAREN_PAIRS = {
    "p" => ["(", ")"],
    "b" => ["[", "]"],
    "c" => ["{", "}"],
    "v" => ["|", "|"],
    "vv" => ["||", "||"],
    "f" => ["\u230A", "\u230B"],
    "g" => ["\u2308", "\u2309"],
    "a" => ["\u27E8", "\u27E9"],
    "aa" => ["\u27EA", "\u27EB"]
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

  def create_row(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("mrow") do |this|
      this << children_list.first
    end
    return this
  end

  def create_superscript(name, attributes, children_list)
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

  def create_paren(name, attributes, children_list)
    this = Nodes[]
    pair = PAREN_PAIRS[name]
    this << Element.build("mfenced") do |this|
      this["open"] = pair[0]
      this["close"] = pair[1]
      children_list.each do |children|
        this << Element.build("mrow") do |this|
          this << children
        end
      end
    end
    return this
  end

end