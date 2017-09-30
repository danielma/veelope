class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def as_json(*args)
    { self.class.to_s.underscore => super }
  end
end
