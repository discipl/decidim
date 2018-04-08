# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Custom helpers, scoped to the meetings admin engine.
      #
      module ApplicationHelper
        include Decidim::MapHelper

        def tabs_id_for_registration_question(question)
          "meeting_registration_question_#{question.to_param}"
        end
      end
    end
  end
end
