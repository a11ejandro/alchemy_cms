# frozen_string_literal: true

module Alchemy
  # Module concerning element definitions
  #
  module Element::Definitions
    extend ActiveSupport::Concern

    module ClassMethods
      # Returns the definitions from elements.yml file.
      #
      # Place a +elements.yml+ file inside your apps +config/alchemy+ folder to define
      # your own set of elements
      #
      def definitions
        @definitions ||= read_definitions_files.map(&:with_indifferent_access)
      end

      # Returns one element definition by given name.
      #
      def definition_by_name(name)
        definitions.detect { |d| d['name'] == name }
      end

      private

      # Reads the element definitions folder named +elements+ from +config/alchemy/+ folder.
      #
      def read_definitions_files
        if ::Dir.exist?(definitions_files_path)
          ::Dir.new(definitions_files_path).each.each_with_object([]) do |file, memo|
            if file.include?('.yml')
              memo << ::YAML.safe_load(ERB.new(File.read(Rails.root.join("config/alchemy/elements/#{file}"))).result, YAML_WHITELIST_CLASSES, [], true) || []
            end
          end.flatten
        else
          raise LoadError, "Could not find elements folder with files! Please run `rails generate alchemy:scaffold`"
        end
      end
      
      # Returns the +elements+ folder path
      #
      def definitions_files_path
        Rails.root.join('config/alchemy/elements')
      end
    end

    # The definition of this element.
    #
    def definition
      if definition = self.class.definitions.detect { |d| d['name'] == name }
        definition
      else
        log_warning "Could not find element definition for #{name}. Please check your elements.yml file!"
        {}
      end
    end
  end
end
