module Workbench::VizHelper
  def graph_viz_tag()
    content_tag(:span, '', data: { "diagram": 'digraph { a -> b }', 'graph-viz': 'true'})
  end

  def graph_javascript_tag
    content_for :head do
      javascript_include_tag "https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js",
        "https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3.0.0/dist/chartjs-adapter-date-fns.bundle.min.js"
    end
  end

end
  
  
