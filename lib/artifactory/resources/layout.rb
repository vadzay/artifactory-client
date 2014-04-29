require 'rexml/document'

include REXML

module Artifactory
  class Resource::Layout < Resource::Base
    class << self
      #
      # Get a list of all repository layouts in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<String>]
      #   the list of layouts
      #
      def all(options = {})
        config = Resource::System.configuration(options)
        list_from_config("config/repoLayouts/repoLayout", config, options)
      end

      #
      # Find (fetch) a layout by its name.
      #
      # @example Find a layout by its name
      #   Layout.find('maven-2-default') #=> #<Layout name: 'maven-2-default' ...>
      #
      # @param [String] name
      #   the name of the layout to find
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::Layout, nil]
      #   an instance of the layout that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options = {})
        client = extract_client!(options)
        config = Resource::System.configuration(options)

        name_node = XPath.match(config, "config/repoLayouts/repoLayout/name[text()='#{name}']")
        properties = Hash.new
        name_node[0].parent.each_element_with_text do |e|
          properties[e.name] = e.text
        end

        from_hash(properties, client: client)
      rescue Error::HTTPError => e
        raise unless e.code == 404
        nil
      end
    end

    attribute :name
    attribute :artifact_path_pattern
    attribute :distinctive_descriptor_path_pattern
    attribute :descriptor_path_pattern
    attribute :folder_integration_revision_reg_exp
    attribute :file_integration_revision_reg_exp

  end
end
