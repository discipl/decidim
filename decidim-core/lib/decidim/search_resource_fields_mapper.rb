# frozen_string_literal: true

module Decidim
  # A class with the responsibility to mapp fields between a Searchalbe and a SearchableRsrc.
  class SearchResourceFieldsMapper
    def initialize(declared_fields)
      @declared_fields = declared_fields.with_indifferent_access
    end

    def mapped(resource)
      fields = map_common_fields(resource)
      fields[:i18n] = map_i18n_fields(resource)
      fields
    end

    private

    def map_common_fields(resource)
      participatory_space = read_field(resource, @declared_fields, :participatory_space)
      @organization = participatory_space.organization
      {
        decidim_scope_id: read_field(resource, @declared_fields, :scope_id),
        decidim_participatory_space_id: participatory_space.id,
        decidim_participatory_space_type: participatory_space.class.name,
        decidim_organization_id: @organization.id
      }
    end

    def read_field(resource, fields, field_name)
      if fields[field_name].is_a?(Hash)
        fields = fields[field_name]
        parent_field_name = fields.keys.first
        intermediate_model = resource.send(parent_field_name.to_sym)
        read_field(intermediate_model, fields, parent_field_name)
      else
        value_field = fields[field_name]
        if value_field.is_a?(Array)
          value_field.collect do |vfield_name|
            raise ArgumentError, "nested fields not supported for translations" if vfield_name.is_a?(Hash)
            resource.send(vfield_name.to_sym)
          end
        else
          resource.send(value_field.to_sym) unless value_field.nil?
        end
      end
    end

    def map_i18n_fields(resource)
      i18n = {}
      @organization.available_locales.each do |locale|
        content_a = read_i18n_field(resource, locale, :A)
        content_b = read_i18n_field(resource, locale, :B)
        content_c = read_i18n_field(resource, locale, :C)
        content_d = read_i18n_field(resource, locale, :D)
        i18n[locale] = { A: content_a, B: content_b, C: content_c, D: content_d }
      end
      i18n
    end

    def read_i18n_field(resource, locale, field_name)
      content = read_field(resource, @declared_fields, field_name)
      return if content.nil?
      content = Array.wrap(content).collect do |item|
        item.is_a?(Hash) ? item[locale] : item
      end
      content.respond_to?(:join) ? content.join(" ") : content
    end
  end
end
