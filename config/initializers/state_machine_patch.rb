# Patch state_machine_deuxito for Rails 6.1 + Ruby 3.1 compatibility.
#
# Rails 6.1 changed ActiveRecord::Suppressor#save signature from save(*) to save(**).
# The state_machine gem defines save(*) and calls super, which forwards positional
# args to a keyword-only method, causing ArgumentError in Ruby 3.0+.
#
# This patch changes the generated save/save! methods to use (**) instead of (*).

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
