# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: meeting_component.organization }
  let(:space_allows) { true }
  let(:context) do
    {
      current_component: meeting_component,
      meeting: meeting
    }
  end
  let(:meeting_component) { create :meeting_component }
  let(:meeting) { create :meeting, component: meeting_component }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:registrations_enabled) { true }
  let(:action) do
    { scope: :admin, action: action_name, subject: :meeting }
  end
  let(:action_name) { :foo }

  shared_examples "action requiring a meeting" do
    context "when meeting is present" do
      it { is_expected.to eq true }
    end

    context "when meeting is missing" do
      let(:meeting) { nil }

      it_behaves_like "permission is not set"
    end
  end

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :meeting }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a meeting" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when action is a random one" do
    let(:action_name) { :foo }

    it_behaves_like "permission is not set"
  end

  context "when creating a meeting" do
    let(:action_name) { :create }

    it { is_expected.to eq true }
  end

  context "when closing a meeting" do
    let(:action_name) { :close }

    it_behaves_like "action requiring a meeting"
  end

  context "when copying a meeting" do
    let(:action_name) { :copy }

    it_behaves_like "action requiring a meeting"
  end

  context "when destroying a meeting" do
    let(:action_name) { :destroy }

    it_behaves_like "action requiring a meeting"
  end

  context "when exporting registrations a meeting" do
    let(:action_name) { :export_registrations }

    it_behaves_like "action requiring a meeting"
  end

  context "when inviting a user a meeting" do
    let(:action_name) { :invite_user }
    let(:meeting) { create :meeting, registrations_enabled: true, component: meeting_component }

    it_behaves_like "action requiring a meeting"

    context "when the meeting registrations are closed" do
      let(:meeting) { create :meeting, registrations_enabled: false, component: meeting_component }

      it_behaves_like "permission is not set"
    end
  end

  context "when updating a meeting" do
    let(:action_name) { :update }

    it_behaves_like "action requiring a meeting"
  end
end
