module Alchemy
  module Page::Natures
    
    extend ActiveSupport::Concern

    def taggable?
      definition['taggable'] == true
    end

    def rootpage?
      !self.new_record? && self.parent_id.blank?
    end

    def systempage?
      return true if Page.root.nil?
      rootpage? || (self.parent_id == Page.root.id && !self.language_root?)
    end

    def folded?(user_id)
      folded_page = folded_pages.find_by_user_id(user_id)
      folded_page.try(:folded) || false
    end

    def contains_feed?
      definition["feed"]
    end

    # Returns true or false if the pages layout_description for config/alchemy/page_layouts.yml contains redirects_to_external: true
    def redirects_to_external?
      definition["redirects_to_external"]
    end

    def has_controller?
      !PageLayout.get(self.page_layout).nil? && !PageLayout.get(self.page_layout)["controller"].blank?
    end

    def controller_and_action
      if self.has_controller?
        {
          controller: self.layout_description["controller"].gsub(/(^\b)/, "/#{$1}"),
          action: self.layout_description["action"]
        }
      end
    end

    # Returns a Hash describing the status of the Page.
    #
    def status
      {
        visible: visible?,
        public: public?,
        locked: locked?,
        restricted: restricted?
      }
    end

    # Returns the translated status for given status type.
    #
    # @param [Symbol] status_type
    #
    def status_title(status_type)
      I18n.t(self.status[status_type].to_s, scope: "page_states.#{status_type}")
    end

    # Returns the self#page_layout description from config/alchemy/page_layouts.yml file.
    def layout_description
      return {} if self.systempage?
      description = PageLayout.get(self.page_layout)
      if description.nil?
        raise PageLayoutDefinitionError, "Description could not be found for page layout named #{self.page_layout}. Please check page_layouts.yml file."
      else
        description
      end
    end
    alias_method :definition, :layout_description

    # Returns translated name of the pages page_layout value.
    # Page layout names are defined inside the config/alchemy/page_layouts.yml file.
    # Translate the name in your config/locales language yml file.
    def layout_display_name
      I18n.t(self.page_layout, :scope => :page_layout_names)
    end

    # Overwrites the cache_key method.
    def cache_key(request = nil)
      "alchemy/pages/#{id}"
    end

  end
end
