# frozen_string_literal: true

class AddQuestionsAttributesToMeetingRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_meetings_meetings, :registration_questions, :jsonb, default: []
    add_column :decidim_meetings_registrations, :questions_answers, :jsonb, default: []
  end
end
