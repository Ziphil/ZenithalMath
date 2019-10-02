# coding: utf-8


require 'pp'
require 'rexml/document'
include REXML


module ZenithalMathCreater

  CREATION_METHODS = {
    "row" => :row,
    "sp" => :superscript, "sb" => :superscript, "sbsp" => :bothscript,
    "frac" => :fraction, "dfrac" => :fraction,
    "sqrt" => :radical,
    "int" => :integral,
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
  INTEGRALS = {
    "int" => "\u222B",
    "oint" => "\u222E"
  }
  FUNCTIONS = [
    "sin", "cos", "tan", "cot", "sec", "csc", "sinh", "cosh", "tanh",
    "log", "ln", "lg", "exp",
    "inf", "sup", "min", "max",
    "ker", "im",
    "lim", "colim",
    "deg", "dim", "det", "sgn", "arg"
  ]
  OPERATORS = {
    "pm" => "\u00B1",
    "coloneq" => ":="
  }
  GREEKS = {
    "a" => "α", "b" => "β", "c" => "ψ", "d" => "δ", "e" => "ε", "f" => "φ", "g" => "γ", "h" => "η", "i" => "ι", "j" => "ξ", "k" => "κ", "l" => "λ", "m" => "μ", 
    "n" => "ν", "o" => "ο", "p" => "π", "q" => "ϕ", "r" => "ρ", "s" => "σ", "t" => "τ", "u" => "θ", "v" => "ω", "w" => "ς", "x" => "χ", "y" => "υ", "z" => "ζ",
    "A" => "Α", "B" => "Β", "C" => "Ψ", "D" => "Δ", "E" => "Ε", "F" => "Φ", "G" => "Γ", "H" => "Η", "I" => "Ι", "J" => "Ξ", "K" => "Κ", "L" => "Λ", "M" => "Μ", 
    "N" => "Ν", "O" => "Ο", "P" => "Π", "Q" => "Φ", "R" => "Ρ", "S" => "Σ", "T" => "Τ", "U" => "Θ", "V" => "Ω", "W" => "Σ", "X" => "Χ", "Y" => "Υ", "Z" => "Ζ"
  }

  private

  def create_math_element(name, attributes, children_list)
    nodes = Nodes[]
    if PAREN_PAIRS.key?(name)
      nodes = send("create_paren", name, attributes, children_list)
    elsif INTEGRALS.key?(name)
      nodes = send("create_integral", name, attributes, children_list)
    elsif FUNCTIONS.include?(name)
      nodes = send("create_function", name, attributes, children_list)
    elsif OPERATORS.key?(name)
      nodes = send("create_operator", name, attributes, children_list)
    elsif CREATION_METHODS.key?(name)
      method_name = CREATION_METHODS[name]
      nodes = send("create_#{method_name}", name, attributes, children_list)
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
      elsif char =~ /[[:alpha:]]/
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

  def create_math_escape(char)
    next_char = char
    if GREEKS.key?(char)
      next_char = GREEKS[char]
    end
    return next_char
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
    element_name = (name == "sp") ? "msup" : "msub"
    this << Element.build(element_name) do |this|
      this << Element.build("mrow") do |this|
        this << children_list[0]
      end
      this << Element.build("mrow") do |this|
        this << children_list[1]
      end
    end
    return this
  end

  def create_bothscript(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("msubsup") do |this|
      this << Element.build("mrow") do |this|
        this << children_list[0]
      end
      this << Element.build("mrow") do |this|
        this << children_list[1]
      end
      this << Element.build("mrow") do |this|
        this << children_list[2]
      end
    end
    return this
  end

  def create_paren(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("mfenced") do |this|
      this["open"], this["close"] = PAREN_PAIRS[name]
      children_list.each do |children|
        this << Element.build("mrow") do |this|
          this << children
        end
      end
    end
    return this
  end

  def create_function(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("mi") do |this|
      this << ~name
    end
    this << Element.build("mo") do |this|
      this << ~"\u2061"
    end
    return this
  end

  def create_operator(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("mo") do |this|
      this << ~OPERATORS[name]
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
          this << children_list[0]
        end
        this << Element.build("mrow") do |this|
          this << children_list[1]
        end
      end
    end
    return this
  end

  def create_integral(name, attributes, children_list)
    this = Nodes[]
    this << Element.build("msubsup") do |this|
      this << Element.build("mo") do |this|
        this << ~INTEGRALS[name]
      end
      if children_list.size >= 2
        this << Element.build("mrow") do |this|
          this << children_list[0]
        end
        this << Element.build("mrow") do |this|
          this << children_list[1]
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