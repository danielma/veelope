module CustomAssertions
  def assert_valid(model, message = "")
    return if model.valid?

    message = [
      message,
      "Expected #{model.inspect} to be valid. Errors: #{model.errors.full_messages.to_sentence}"
    ]

    flunk message.compact.join("\n")
  end

  def refute_valid(model, message = "")
    refute_predicate model, :valid?, message
  end
end
