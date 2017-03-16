module Service
  extend ActiveSupport::Concern

  module ClassMethods
    def call(*args)
      new(*args).call
    end

    def call!(*args)
      new(*args).call!
    end
  end

  def success(**attributes)
    SuccessResult.new(attributes)
  end

  def failure(message, **extras)
    FailureResult.new(extras.merge(message: message))
  end

  class Result
    def initialize(**attributes)
      fail("Only use subclasses") if self.class == Result

      @attributes = attributes.symbolize_keys
    end

    def respond_to_missing?(method_name, _include_private = false)
      attributes.key?(method_name)
    end

    def method_missing(method_name, *args)
      attributes.fetch(method_name) { super }
    end

    private

    attr_reader :attributes
  end

  class SuccessResult < Result
    def ok?
      true
    end
  end

  class FailureResult < Result
    def ok?
      false
    end
  end
end
