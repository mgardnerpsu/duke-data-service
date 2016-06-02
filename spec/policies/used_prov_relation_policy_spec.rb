require 'rails_helper'

describe UsedProvRelationPolicy do
  include_context 'policy declarations'

  let(:auth_role) { FactoryGirl.create(:auth_role) }
  let(:project_permission) { FactoryGirl.create(:project_permission, auth_role: auth_role) }
  let(:user) { project_permission.user }
  let(:other_user) { FactoryGirl.create(:user) }

  let(:data_file) { FactoryGirl.create(:data_file, project: project_permission.project) }
  let(:file_version) { FactoryGirl.create(:file_version, data_file: data_file) }
  let(:activity) { FactoryGirl.create(:activity, creator: user) }
  let(:other_user_activity) { FactoryGirl.create(:activity, creator: other_user) }

  let(:used_prov_relation) { FactoryGirl.create(:used_prov_relation, creator: user, relatable_from: activity, relatable_to: file_version) }
  let(:used_prov_relation_creator) { used_prov_relation.creator }
  let(:other_used_prov_relation) { FactoryGirl.create(:used_prov_relation) }

  let(:from_users_activity_to_invisible_file_version) { FactoryGirl.create(:used_prov_relation, relatable_from: activity) }
  let(:from_other_users_activity_to_visible_file_version) { FactoryGirl.create(:used_prov_relation,
    relatable_from: other_user_activity,
    relatable_to: file_version)
  }

  it_behaves_like 'system_permission can access', :used_prov_relation, allows: [:scope, :show?, :create?, :destroy?], denies: [:index?, :update?]
  it_behaves_like 'system_permission can access', :other_used_prov_relation, allows: [:scope, :show?, :create?, :destroy?], denies: [:index?, :update?]
  it_behaves_like 'system_permission can access', :from_users_activity_to_invisible_file_version, allows: [:scope, :show?, :create?, :destroy?], denies: [:index?, :update?]
  it_behaves_like 'system_permission can access', :from_other_users_activity_to_visible_file_version, allows: [:scope, :show?, :create?, :destroy?], denies: [:index?, :update?]

  context 'destroy' do
    it_behaves_like 'a policy for', :used_prov_relation_creator, on: :used_prov_relation, allows: [:destroy?]
    it_behaves_like 'a policy for', :used_prov_relation_creator, on: :other_used_prov_relation, allows: [], denies: [:show?, :create?, :index?, :update?, :destroy?]
  end

  context 'user created activity and has visibility to the file_version' do
    it_behaves_like 'a user with project_permission', :view_project, allows: [:show?, :create?, :destroy?], on: :used_prov_relation
    it_behaves_like 'a user without project_permission', :view_project, denies: [:show?, :create?], on: :used_prov_relation
  end

  context 'user did not create activity and does not have visibility to the file_version' do
    it_behaves_like 'a user with project_permission', :view_project, allows: [], on: :other_used_prov_relation
    it_behaves_like 'a user without project_permission', :view_project, denies: [:show?, :create?, :destroy?], on: :other_used_prov_relation
  end

  context 'user created the activity but does not have visbility to the file_version' do
    it_behaves_like 'a user with project_permission', :view_project, allows: [], on: :from_users_activity_to_invisible_file_version
    it_behaves_like 'a user without project_permission', :view_project, denies: [:show?, :create?, :destroy?], on: :from_users_activity_to_invisible_file_version
  end

  context 'user did not create the activity but has visibility to the file_version' do
    it_behaves_like 'a user with project_permission', :view_project, allows: [:show?], on: :from_other_users_activity_to_visible_file_version
    it_behaves_like 'a user without project_permission', :view_project, denies: [:show?, :create?, :destroy?], on: :from_other_users_activity_to_visible_file_version
  end
end
