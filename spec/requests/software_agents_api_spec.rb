require 'rails_helper'

describe DDS::V1::SoftwareAgentsAPI do
  include_context 'with authentication'

  let(:software_agent) { FactoryGirl.create(:software_agent) }
  let(:deleted_software_agent) { FactoryGirl.create(:software_agent, :deleted) }
  let(:software_agent_stub) { FactoryGirl.build(:software_agent) }
  let(:system_permission) { FactoryGirl.create(:system_permission, user: current_user) }

  let(:resource_class) { SoftwareAgent }
  let(:resource_serializer) { SoftwareAgentSerializer }
  let!(:resource) { software_agent }
  let(:resource_stub) { software_agent_stub }
  let!(:resource_permission) { system_permission }

  describe 'SoftwareAgent collection' do
    let(:url) { "/api/v1/software_agents" }

    describe 'GET' do
      subject { get(url, nil, headers) }
      it_behaves_like 'a listable resource' do
        let(:unexpected_resources) { [
          deleted_software_agent
        ] }
      end

      it_behaves_like 'an authenticated resource'
    end

    describe 'POST' do
      subject { post(url, payload.to_json, headers) }
      let(:called_action) { "POST" }
      let(:payload) {{
        name: resource.name
      }}
      it_behaves_like 'a creatable resource' do
        let(:resource) { resource_stub }
        it 'should set creator to current_user' do
          is_expected.to eq(201)
          expect(new_object.creator_id).to eq(current_user.id)
        end
      end

      it_behaves_like 'an authenticated resource'

      it_behaves_like 'a validated resource' do
        let!(:payload) {{
          name: nil
        }}
        it 'should not persist changes' do
          expect(resource).to be_persisted
          expect {
            is_expected.to eq(400)
          }.not_to change{resource_class.count}
        end
      end

      it_behaves_like 'an audited endpoint' do
        let(:expected_status) { 201 }
      end
    end
  end
  describe 'SoftwareAgent instance' do
    let(:url) { "/api/v1/software_agents/#{resource.id}" }

    describe 'GET' do
      subject { get(url, nil, headers) }
      it_behaves_like 'a viewable resource'
      it_behaves_like 'an authenticated resource'
    end

    describe 'PUT' do
      subject { put(url, payload.to_json, headers) }
      let(:called_action) { 'PUT' }
      let(:payload) {{
        name: resource_stub.name,
        description: resource_stub.description
      }}
      it_behaves_like 'an updatable resource'

      it_behaves_like 'a validated resource' do
        let(:payload) {{
            name: nil
        }}
      end

      it_behaves_like 'an authenticated resource'
      it_behaves_like 'an authorized resource'
      it_behaves_like 'an audited endpoint'
      it_behaves_like 'a logically deleted resource'
    end
  end
end
