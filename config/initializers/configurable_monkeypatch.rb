# remove when https://github.com/paulca/configurable_engine/pull/11 gets merged
module ConfigurableEngine
  module ConfigurablesController
    def update
      Configurable.keys.each do |key|
        configurable = Configurable.find_by_name(key) ||
          Configurable.create {|c| c.name = key}
        configurable.update_attribute(:value,params[key])
      end
      redirect_to admin_configurable_path
    end
  end
end
