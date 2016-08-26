require 'rails_helper'

describe DDS::V1::TemplatesAPI do
  include_context 'with authentication'

  let(:project) { FactoryGirl.create(:project) }
  let(:template) { FactoryGirl.create(:template) }
  let(:template_stub) { FactoryGirl.build(:template) }
  let(:other_template) { FactoryGirl.create(:template) }
  let(:system_permission) { FactoryGirl.create(:system_permission, user: current_user) }

  let(:resource_class) { Template }
  let(:resource_serializer) { TemplateSerializer }
  let!(:resource) { template }
  let!(:resource_id) { resource.id }
  let!(:resource_permission) { system_permission }
  let(:resource_stub) { template_stub }

  describe 'Templates collection' do
    let(:url) { "/api/v1/templates" }

    describe 'POST' do
      subject { post(url, payload.to_json, headers) }
      let(:called_action) { 'POST' }
      let!(:payload) {{
        name: payload_name,
        label: resource_stub.label,
        description: resource_stub.description
      }}
      let(:payload_name) { resource_stub.name }

      it_behaves_like 'a creatable resource' do
        it 'should set creator to current_user' do
          is_expected.to eq(201)
          expect(new_object.creator_id).to eq(current_user.id)
        end
      end
      it_behaves_like 'an authenticated resource'
      it_behaves_like 'a software_agent accessible resource' do
        let(:expected_response_status) { 201 }
      end

      context 'with blank name' do
        let(:payload_name) { '' }
        it_behaves_like 'a validated resource'
      end

      context 'with existing name' do
        let(:payload_name) { resource.name }
        it_behaves_like 'a validated resource'
      end
    end

    describe 'GET' do
      subject { get(url, nil, headers) }
    end
  end

  describe 'Template instance' do
    let(:url) { "/api/v1/templates/#{resource_id}" }

    describe 'GET' do
      subject { get(url, nil, headers) }
    end

    describe 'PUT' do
      subject { put(url, payload.to_json, headers) }
      let(:called_action) { 'PUT' }
      let(:payload) {{
      }}
    end

    describe 'DELETE' do
      subject { delete(url, nil, headers) }
      let(:called_action) { 'DELETE' }
    end
  end
end
