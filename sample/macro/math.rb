# coding: utf-8


parser.register_math_macro("m") do |attributes, children_list|
  this = Nodes[]
  this << Element.build("inline-math") do |this|
    this << children_list.first
  end
  next this
end

parser.register_math_macro("mb") do |attributes, children_list|
  this = Nodes[]
  this << Element.build("block-math") do |this|
    children = children_list.first
    children["display"] = "block"
    this << children
  end
  next this
end