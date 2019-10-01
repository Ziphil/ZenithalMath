# coding: utf-8


parser.register_math_macro("m") do |attributes, children_list|
  this = Nodes[]
  this << Element.build("fo:instream-foreign-object") do |this|
    this << children_list.first
  end
  next this
end