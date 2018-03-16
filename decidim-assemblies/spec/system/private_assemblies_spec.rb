# frozen_string_literal: true

require "spec_helper"

describe "Private Assemblies", type: :system do
  let!(:organization) { create(:organization) }
  let!(:assembly) { create :assembly, :published, organization: organization }
  let!(:private_assembly) { create :assembly, :published, organization: organization, private_space: true }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:other_user) { create :user, :confirmed, organization: organization }
  let!(:assembly_private_user) { create :assembly_private_user, user: other_user, privatable_to: private_assembly }

  context "when there are private assemblies" do
    context "and no user is loged in" do
      before do
        switch_to_host(organization.host)
        visit decidim_assemblies.assemblies_path
      end

      it "lists only the not private assembly" do
        within "#assemblies-grid" do
          within "#assemblies-grid h2" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(assembly.title, locale: :en))
          expect(page).to have_selector("article.card", count: 1)

          expect(page).to have_no_content(translated(private_assembly.title, locale: :en))
        end
      end
    end

    context "when user is loged in and is not a assembly private user" do
      before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim_assemblies.assemblies_path
      end

      it "lists only the not private assembly" do
        within "#assemblies-grid" do
          within "#assemblies-grid h2" do
            expect(page).to have_content("1")
          end

          expect(page).to have_content(translated(assembly.title, locale: :en))
          expect(page).to have_selector("article.card", count: 1)

          expect(page).to have_no_content(translated(private_assembly.title, locale: :en))
        end
      end
    end

    context "when user is loged in and is assembly private user" do
      before do
        switch_to_host(organization.host)
        login_as other_user, scope: :user
        visit decidim_assemblies.assemblies_path
      end

      it "lists private assemblies" do
        within "#assemblies-grid" do
          within "#assemblies-grid h2" do
            expect(page).to have_content("2")
          end

          expect(page).to have_content(translated(assembly.title, locale: :en))
          expect(page).to have_content(translated(private_assembly.title, locale: :en))
          expect(page).to have_selector("article.card", count: 2)
        end
      end

      it "links to the individual assembly page" do
        click_link(translated(private_assembly.title, locale: :en))

        expect(page).to have_current_path decidim_assemblies.assembly_path(private_assembly)
        expect(page).to have_content "This is a private assembly"
      end
    end
  end
end
