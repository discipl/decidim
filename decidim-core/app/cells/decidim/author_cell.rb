# frozen_string_literal: true

module Decidim
  # This cell renders the author of a resource. It is intended to be used
  # below resource titles to indicate its authorship & such, and is intended
  # for resources that have a single author.
  class AuthorCell < Decidim::ViewModel
    include LayoutHelper
    include Devise::Controllers::Helpers
    include Devise::Controllers::UrlHelpers
    include Messaging::ConversationHelper

    property :profile_path

    def show
      render
    end

    def profile
      render
    end

    def profile_inline
      render
    end

    # delegate :user_signed_in?, :current_user, to: :parent_controller

    private

    def from_context
      from_context = options[:from] if options[:from].present?
      from_context = context[:from] if context[:from].present?
      from_context
    end

    def from_context_path
      resource_locator(from_context).path
    end

    def withdraw_path
      from_context_path + "/withdraw"
    end

    def withdrawable?
      return unless proposals_controller?
      return if index_action?
      from_context.withdrawable_by?(current_user)
    end

    def flagable?
      return unless proposals_controller?
      return if index_action?
      return if from_context.official?
      true
    end

    def author_box_classes
      (["author-data"] + options[:extra_classes].to_a).join(" ")
    end

    def actionable?
      # true if proposals_controller? && index_action? && @options[:extra]
      true if user_author? && proposals_controller? && index_action?
    end

    def user_author?
      true if "Decidim::UserPresenter".include? model.class.to_s
    end

    def proposals_controller?
      context[:controller].class.to_s == "Decidim::Proposals::ProposalsController"
    end

    def index_action?
      context[:controller].action_name == "index"
    end

    def current_component
      from_context.component
    end

    def profile_path?
      profile_path.present?
    end
  end
end
