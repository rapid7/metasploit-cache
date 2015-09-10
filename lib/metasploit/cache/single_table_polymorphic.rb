# This concern will grab the polymorphic associations and ensure that the record is always saved to using the base
# class.
#
# @see http://stackoverflow.com/a/23520335/470451
module Metasploit::Cache::SingleTablePolymorphic
  # @note {use} must be called after associations are declared.
  #
  # Allows an STI subclass `klass` to be used in a polymorphic associations.
  def self.use(klass)
    klass.reflect_on_all_associations.each do |association|
      if association.options[:polymorphic]
        klass.send(:define_method, "#{association.name}_type=") do |class_name|
          super(class_name.constantize.base_class.name)
        end
      end
    end
  end
end