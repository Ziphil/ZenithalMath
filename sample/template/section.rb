# coding: utf-8


converter.set("section.page-master") do |element|
  this = Nodes[]
  this << Element.build_page_master do |this|
    this["master-name"] = "section.left"
    this << Element.build_region_body(:left) do |this|
      this["region-name"] = "section.body"
    end
    this << Element.build_region_before do |this|
      this["region-name"] = "section.left-header"
    end
    this << Element.build_region_after do |this|
      this["region-name"] = "section.left-footer"
    end
  end
  this << Element.build_page_master do |this|
    this["master-name"] = "section.right"
    this << Element.build_region_body(:right) do |this|
      this["region-name"] = "section.body"
    end
    this << Element.build_region_before do |this|
      this["region-name"] = "section.right-header"
    end
    this << Element.build_region_after do |this|
      this["region-name"] = "section.right-footer"
    end
  end
  this << Element.build("fo:page-sequence-master") do |this|
    this["master-name"] = "section"
    this << Element.build("fo:repeatable-page-master-alternatives") do |this|
      this << Element.build("fo:conditional-page-master-reference") do |this|
        this["master-reference"] = "section.left"
        this["odd-or-even"] = "even"
      end
      this << Element.build("fo:conditional-page-master-reference") do |this|
        this["master-reference"] = "section.right"
        this["odd-or-even"] = "odd"
      end
    end
  end
  next this
end

converter.add(["section"], [""]) do |element|
  this = Nodes[]
  this << Element.build("fo:page-sequence") do |this|
    this["master-reference"] = "section"
    this["initial-page-number"] = "auto-even"
    this << Element.build("fo:static-content") do |this|
      this["flow-name"] = "section.left-header"
    end
    this << Element.build("fo:static-content") do |this|
      this["flow-name"] = "section.right-header"
    end
    this << Element.build("fo:static-content") do |this|
      this["flow-name"] = "section.left-footer"
    end
    this << Element.build("fo:static-content") do |this|
      this["flow-name"] = "section.right-footer"
    end
    this << Element.build("fo:flow") do |this|
      this["flow-name"] = "section.body"
      this << Element.build("fo:block-container") do |this|
        this << apply(element, "section")
      end
    end
  end
  next this
end

converter.add(["h"], ["section"]) do |element|
  this = Nodes[]
  number = element.each_xpath("../preceding::section").to_a.size + 1
  this << Element.build("fo:block") do |this|
    this["space-before"] = "3mm"
    this["space-after"] = "3mm"
    this.make_elastic("space-before")
    this.make_elastic("space-after")
    this["font-size"] = "1.5em"
    this.justify_text
    this << Element.build("fo:inline") do |this|
      this["font-family"] = SANS_FONT_FAMILY
      this["font-size"] = SANS_FONT_SIZE
      this << Element.build("fo:inline") do |this|
        this["margin-right"] = "0.5em"
        this << ~"#{number}."
      end
      this << apply(element, "section")
    end
  end
  next this
end

converter.add(["p"], ["section"]) do |element|
  this = Nodes[]
  this << Element.build("fo:block") do |this|
    this["space-before"] = "2mm"
    this["space-after"] = "2mm"
    this.make_elastic("space-before")
    this.make_elastic("space-after")
    this.justify_text
    this["text-indent"] = "1em"
    this << apply(element, "section")
  end
  next this
end

converter.add([//], ["section"]) do |element|
  this = Nodes[]
  this << Element.build(element.expanded_name) do |this|
    element.attributes.each_attribute do |attribute|
      this[attribute.name] = attribute.to_s
    end
    this << apply(element, "section")
  end
  next this
end

converter.add(nil, ["section"]) do |text|
  this = Nodes[]
  this << ~text.to_s.gsub(/(?<=。)\s*\n\s*/, "")
  next this
end