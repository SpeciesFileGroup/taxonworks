module Workbench::VizHelper
  def graph_viz_tag()
    content_tag(:span, '', data: { "diagram": 'digraph { a -> b }', 'graph-viz': 'true'})
  end
end
  
  
