# Patch state_machine_deuxito for Rails 6.1 + Ruby 3.1 compatibility.
#
# Rails 6.1 changed ActiveRecord::Suppressor#save from save(*) to save(**).
# The state_machine gem defines save(*) and calls super, forwarding positional
# args to a keyword-only method, causing ArgumentError in Ruby 3.0+.

module StateMachine
  module Integrations
    module ActiveRecord
      def define_action_hook
        if action_hook == :save
          define_helper :instance, <<-END_EVAL, __FILE__, __LINE__ + 1
            def save(**)
              self.class.state_machine(#{name.inspect}).send(:around_save, self) { super }
            end

            def save!(**)
              self.class.state_machine(#{name.inspect}).send(:around_save, self) { super } || raise(::ActiveRecord::RecordInvalid.new(self))
            end

            def changed_for_autosave?
              super || self.class.state_machines.any? {|name, machine| machine.action == :save && machine.read(self, :event)}
            end
          END_EVAL
        else
          super
        end
      end
    end
  end
end

# Rails 6.1 changed ActiveModel::Errors#add to use keyword arguments:
#   def add(attribute, type = :invalid, **options)
# The state_machine gem passes options as a positional hash argument.
# Patch invalidate to splat options as keyword arguments.
module StateMachine
  module Integrations
    module ActiveModel
      def invalidate(object, attribute, message, values = [])
        if supports_validations?
          attribute = self.attribute(attribute)
          options = values.inject({}) do |h, (key, value)|
            h[key] = value
            h
          end

          default_options = default_error_message_options(object, attribute, message)
          object.errors.add(attribute, message, **options.merge(default_options))
        end
      end
    end
  end
end
