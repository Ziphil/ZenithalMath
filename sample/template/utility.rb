# coding: utf-8


class Element

  DEBUG_COLORS = ["#FF888888", "#8888FF88", "#88FF8888", "#FF88FF88"]

  def make_elastic(clazz)
    original_space = self[clazz]
    self["#{clazz}.maximum"] = "(#{original_space}) * #{MAXIMUM_RATIO}"
    self["#{clazz}.minimum"] = "(#{original_space}) * #{MINIMUM_RATIO}"
  end

  def reset_indent
    self["start-indent"] = "0mm"
    self["end-indent"] = "0mm"
  end

  def reset_margin
    self["margin-left"] = "0mm"
    self["margin-right"] = "0mm"
  end

  def justify_text
    self["text-align"] = "justify"
    self["axf:text-justify-trim"] = "punctuation ideograph inter-word"
  end

  def debug(number)
    self["background-color"] = DEBUG_COLORS[number]
  end

  def self.build_page_master(&block)
    this = Nodes[]
    this << Element.build("fo:simple-page-master") do |this|
      this["page-width"] = PAGE_WIDTH
      this["page-height"] = PAGE_HEIGHT
      this["axf:bleed"] = BLEED_SIZE
      if DEBUG
        this["background-image"] = "url('../material/blank.svg')"
        this["background-repeat"] = "no-repeat"
      end
      block&.call(this)
    end
    return this
  end

  def self.build_region_body(position, &block)
    this = Nodes[]
    this << Element.build("fo:region-body") do |this|
      this["margin-top"] = PAGE_TOP_SPACE
      this["margin-bottom"] = PAGE_BOTTOM_SPACE
      this["margin-left"] = (position == :left) ? PAGE_OUTER_SPACE : PAGE_INNER_SPACE
      this["margin-right"] = (position == :left) ? PAGE_INNER_SPACE : PAGE_OUTER_SPACE
      block&.call(this)
    end
    return this
  end

  def self.build_spread_region(&block)
    this = Nodes[]
    this << Element.build("axf:spread-region") do |this|
      this["margin-top"] = PAGE_TOP_SPACE
      this["margin-bottom"] = PAGE_BOTTOM_SPACE
      this["margin-left"] = PAGE_OUTER_SPACE 
      this["margin-right"] = PAGE_OUTER_SPACE
      block&.call(this)
    end
    return this
  end

  def self.build_region_before(&block)
    this = Nodes[]
    this << Element.build("fo:region-before") do |this|
      this["extent"] = HEADER_EXTENT
      this["precedence"] = "true"
      block&.call(this)
    end
    return this
  end

  def self.build_region_after(&block)
    this = Nodes[]
    this << Element.build("fo:region-after") do |this|
      this["extent"] = FOOTER_EXTENT
      this["precedence"] = "true"
      block&.call(this)
    end
    return this
  end

  def self.build_region_start(position, &block)
    this = Nodes[]
    this << Element.build("fo:region-start") do |this|
      this["extent"] = (position == :left) ? SIDE_EXTENT : PAGE_INNER_SPACE
      block&.call(this)
    end
    return this
  end

  def self.build_region_end(position, &block)
    this = Nodes[]
    this << Element.build("fo:region-end") do |this|
      this["extent"] = (position == :left) ? PAGE_INNER_SPACE : SIDE_EXTENT
      block&.call(this)
    end
    return this
  end

end