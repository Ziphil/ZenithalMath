# coding: utf-8


require 'pp'
require 'rexml/document'
include REXML


module ZenithalMathCreater

  CREATION_METHODS = {
    "row" => :row,
    "sup" => :superscript, "sub" => :superscript,
    "frac" => :fraction, "dfrac" => :fraction,
    "sqrt" => :radical,
    "display" => :style, "inline" => :style
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
    PAREN_PAIRS.each do |match_name, _|
      if name == match_name
        return send("create_paren", name, attributes, children_list)
      end
    end
    CREATION_METHODS.each do |match_name, method_name|
      if name == match_name
        return send("create_#{method_name}", name, attributes, children_list)
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
      this["open"], this["close"] = pair
      children_list.each do |children|
        this << Element.build("mrow") do |this|
          this << children
        end
      end
    end
    return this
  end

  def create_fraction(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("mfrac") do |this|
      this << Element.build("mrow") do |this|
        this << children_list[0]
      end
      this << Element.build("mrow") do |this|
        this << children_list[1]
      end
    end
    if name == "dfrac"
      next_this = Nodes[]
      next_this << Element.build("mstyle") do |next_this|
        next_this["displaystyle"] = "true"
        next_this << this
      end
      this = next_this
    end
    return this
  end

  def create_radical(name, attributes, children_list)
    this = Nodes[]
    if children_list.size == 1
      this << Element.build("msqrt") do |this|
        this << Element.build("mrow") do |this|
          this << children_list.first
        end
      end
    else
      this << Element.build("mroot") do |this|
        this << Element.build("mrow") do |this|
          this << children_list[1]
        end
        this << Element.build("mrow") do |this|
          this << children_list[0]
        end
      end
    end
    return this
  end

  def create_style(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("mstyle") do |this|
      this["displaystyle"] = (name == "display") ? "true" : "false"
      this << children_list.first
    end
    return this
  end

end