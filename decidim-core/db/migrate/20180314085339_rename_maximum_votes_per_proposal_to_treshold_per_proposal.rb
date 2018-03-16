# frozen_string_literal: true

class RenameMaximumVotesPerProposalToTresholdPerProposal < ActiveRecord::Migration[5.1]
  def up
    execute <<~SQL
      UPDATE decidim_components
      SET settings = jsonb_set(
        settings::jsonb,
        array['global'],
        (settings->'global')::jsonb - 'maximum_votes_per_proposal' || jsonb_build_object('treshold_per_proposal', settings->'global'->'maximum_votes_per_proposal')
        )
      WHERE manifest_name = 'proposals'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE decidim_components
      SET settings = jsonb_set(
        settings::jsonb,
        array['global'],
        (settings->'global')::jsonb - 'treshold_per_proposal' || jsonb_build_object('maximum_votes_per_proposal', settings->'global'->'treshold_per_proposal')
        )
      WHERE manifest_name = 'proposals'
    SQL
  end
end
