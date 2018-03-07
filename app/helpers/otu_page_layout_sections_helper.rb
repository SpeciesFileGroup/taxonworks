module OtuPageLayoutSectionsHelper

  def otu_page_layout_section_tag(otu_page_layout_section)
    return nil if otu_page_layout_section.nil?
    otu_page_layout_section.otu_page_layout.name + ': ' + otu_page_layout_section.topic.name
  end

#  def section_content_tag(otu_page_layout_section, contents)
#    s = otu_page_layout_section
#    return nil if s.nil?
#
#    case s.kind
#
#    when :standard
#      # bad loop
#      contents.each do |c|
#        if c.topic == s.topic
#         return  render('contents/block', content: c) 
#        end
#      end
#
#    when :dynamic
#      return render(s.partial) 
#    else
#      return "oops"
#    end
#
#  end



end
