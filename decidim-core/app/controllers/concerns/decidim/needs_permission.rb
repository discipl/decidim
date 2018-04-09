# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to work with the permissions system
  module NeedsPermission
    extend ActiveSupport::Concern

    included do
      helper_method :allowed_to?

      skip_authorization_check

      class ::Decidim::ActionForbidden < StandardError
      end

      rescue_from Decidim::ActionForbidden, with: :user_has_no_permission

      # Handles the case when a user visits a path that is not allowed to them.
      # Redirects the user to the root path and shows a flash message telling
      # them they are not authorized.
      def user_has_no_permission
        flash[:alert] = t("actions.unauthorized", scope: "decidim.core")
        redirect_to(request.referer || user_has_no_permission_path)
      end

      def user_has_no_permission_path
        raise NotImplementedError
      end

      def permissions_context
        {
          current_settings: try(:current_settings),
          component_settings: try(:component_settings),
          current_organization: try(:current_organization),
          current_component: try(:current_component)
        }
      end

      def enforce_permission_to(action, subject, extra_context = {})
        p "============="
        p permission_scope, action, subject, permission_class
        p "============="
        raise Decidim::ActionForbidden unless allowed_to?(action, subject, extra_context)
      end

      def allowed_to?(action, subject, extra_context = {}, klass = permission_class)
        klass.new(
          current_user,
          Decidim::PermissionAction.new(scope: permission_scope, action: action, subject: subject),
          permissions_context.merge(extra_context)
        ).allowed?
      end

      def permission_class
        raise "Please, make this method return a class"
      end

      def permission_scope
        raise "Please, make this method return a symbol"
      end

      def current_ability
        @current_ability ||= FakeAbility.new(current_user, permissions_context)
      end

      class FakeAbility
        include CanCan::Ability

        def initialize(*); end
      end
    end
  end
end
