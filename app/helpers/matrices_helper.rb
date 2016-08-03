module MatricesHelper

  def matrix_tag(matrix)
    return nil if matrix.nil?
    matrix.name
  end

  def matrices_search_form
    render('/matrices/quick_search_form')
  end

  def matrix_link(matrix)
    return nil if matrix.nil?
    link_to(matrix_tag(matrix).html_safe, matrix)
  end

end
