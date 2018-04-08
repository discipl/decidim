# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting registration questions
      class MeetingRegistrationQuestionForm < Decidim::Form
        include TranslatableAttributes

        attribute :deleted, Boolean, default: false

        translatable_attribute :title, String

        validates :title, translatable_presence: true, unless: :deleted

        def to_param
          id || "meeting-registration-question-id"
        end
      end
    end
  end
end
