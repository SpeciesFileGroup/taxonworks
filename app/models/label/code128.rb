# The label that is to be rendered as a Qr Code
class Label::Code128 < Label

  def is_generated?
    true
  end

end
