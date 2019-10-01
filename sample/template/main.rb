# coding: utf-8


DEBUG = true

EUROPIAN_FONT_FAMILY = "STIX Two Text"
JAPANESE_FONT_FAMILY = "源ノ明朝"
EUROPIAN_SANS_FONT_FAMILY = "FreeSans"
JAPANESE_SANS_FONT_FAMILY = "源ノ角ゴシック"

FONT_SIZE = "11pt"
SANS_FONT_SIZE = "95%"
LINE_HEIGHT = "1.6"

PAGE_WIDTH = "210mm"
PAGE_HEIGHT = "297mm"
PAGE_TOP_SPACE = "30mm"
PAGE_BOTTOM_SPACE = "30mm"
PAGE_INNER_SPACE = "25mm"
PAGE_OUTER_SPACE = "25mm"
HEADER_EXTENT = "20mm"
FOOTER_EXTENT = "20mm"
BLEED_SIZE = "0mm"

MAXIMUM_RATIO = "1.4"
MINIMUM_RATIO = "0.8"

FONT_FAMILY = EUROPIAN_FONT_FAMILY + ", " + JAPANESE_FONT_FAMILY
SANS_FONT_FAMILY = EUROPIAN_SANS_FONT_FAMILY + ", " + JAPANESE_SANS_FONT_FAMILY

converter.add(["root"], [""]) do |element|
  this = Nodes[]
  this << Element.build("fo:root") do |this|
    this["xmlns:fo"] = "http://www.w3.org/1999/XSL/Format"
    this["xmlns:axf"] = "http://www.antennahouse.com/names/XSL/Extensions"
    this["xml:lang"] = "ja"
    this["font-family"] = FONT_FAMILY
    this["font-size"] = FONT_SIZE
    this["line-height"] = "1"
    this["axf:ligature-mode"] = "all"
    this << Element.build("fo:layout-master-set") do |this|
      this << call(element, "section.page-master")
    end
    this << apply(element, "")
  end
  next this
end

converter.add(["x", "xn"], [//]) do |element, scope, *args|
  this = Nodes[]
  this << Element.build("fo:inline") do |this|
    this["font-family"] = SANS_FONT_FAMILY
    this["font-size"] = SANS_FONT_SIZE
    this << apply(element, scope, *args)
  end
  next this
end

converter.add(["i"], [//]) do |element, scope, *args|
  this = Nodes[]
  this << Element.build("fo:inline") do |this|
    this["font-style"] = "italic"
    this << apply(element, scope, *args)
  end
  next this
end

converter.add_default(nil) do |text|
  this = Nodes[]
  this << ~text.to_s
  next this
end