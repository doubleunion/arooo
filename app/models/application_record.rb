require "state_machine" # from gem state_machine_deuxito

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
