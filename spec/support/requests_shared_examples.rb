shared_context 'common headers' do
  let(:common_headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json'} }
end

shared_context 'without authentication' do
  include_context 'common headers'
  let(:headers) { common_headers }
end

shared_context 'with authentication' do
  include_context 'common headers'
  let(:user_auth) { FactoryGirl.create(:user_authentication_service, :populated) }
  let(:current_user) { user_auth.user }
  let (:api_token) { user_auth.api_token }
  let(:headers) {{'Authorization' => api_token}.merge(common_headers)}
end

shared_examples 'a listable resource' do
  let(:expected_list_length) { resource_class.all.count }
  let(:unexpected_resources) { [] }
  before do
    expect(resource).to be_persisted
  end
  it 'should return a list that includes a serialized resource' do
    is_expected.to eq(200)
    expect(response.status).to eq(200)
    expect(response.body).to be
    expect(response.body).not_to eq('null')
    expect(response.body).to include(resource_serializer.new(resource).to_json)
  end

  it 'should include the expected number of results' do
    is_expected.to eq(200)
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('results')
    returned_results = response_json['results']
    expect(returned_results).to be_a(Array)
    expect(returned_results.length).to eq(expected_list_length)
  end

  it 'should not include unexpected resources' do
    expect(unexpected_resources).to be_a(Array)
    is_expected.to eq(200)
    unexpected_resources.each do |unexpected_resource|
      expect(response.body).not_to include(resource_serializer.new(unexpected_resource).to_json)
    end
  end
end

shared_examples 'a paginated resource' do
  let(:expected_total_length) { resource_class.count }
  let(:page) { 2 }
  let(:per_page) { 1 }
  let(:extras) { FactoryGirl.create_list(resource.class.name.downcase.to_sym, 5) }

  let(:pagination_parameters) {
    {
      per_page: per_page,
      page: page
    }
  }

  #paginated_payload must include pagination_parameters
  #if you override it to pass other parameters
  let(:paginated_payload) {
    pagination_parameters
  }

  subject { get(url, paginated_payload, headers) }

  it 'should return pagination response headers' do
     expect(extras.count).to be > per_page
     is_expected.to eq(200)
     response_headers = response.headers
     expect(response_headers).to have_key('X-Total')
     expect(response_headers['X-Total'].to_i).to eq(expected_total_length)
     expect(response_headers).to have_key('X-Total-Pages')
     expect(response_headers['X-Total-Pages'].to_i).to eq(expected_total_length/per_page)
     expect(response_headers).to have_key('X-Page')
     expect(response_headers['X-Page'].to_i).to eq(page)
     expect(response_headers).to have_key('X-Per-Page')
     expect(response_headers['X-Per-Page'].to_i).to eq(per_page)
     expect(response_headers).to have_key('X-Next-Page')
     expect(response_headers['X-Next-Page'].to_i).to eq(page+1)
     expect(response_headers).to have_key('X-Prev-Page')
     expect(response_headers['X-Prev-Page'].to_i).to eq(page-1)
  end

  it 'should return only per_page results' do
    expect(extras.count).to be > per_page
    paginated_payload.merge({per_page: per_page})
    is_expected.to eq(200)
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('results')
    returned_results = response_json['results']
    expect(returned_results).to be_a(Array)
    expect(returned_results.length).to eq(per_page)
  end
end

shared_examples 'a storage_provider backed resource' do

  it 'should return a 500 error and JSON error when a StorageProviderException is experienced' do
    storage_provider.update_attribute(:url_root, "http://257.1.1.1")
    is_expected.to eq(500)
    expect(response.body).to be
    expect(response.body).not_to eq('null')
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq('500')
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq('The storage provider is unavailable')
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq('try again in a few minutes, or contact the systems administrators')
  end
end

shared_examples 'a creatable resource' do
  let(:expected_response_status) {201}
  let(:new_object) {
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('id')
    resource_class.find(response_json['id'])
  }
  it 'should return success' do
    is_expected.to eq(expected_response_status)
    expect(response.status).to eq(expected_response_status)
    expect(response.body).to be
    expect(response.body).not_to eq('null')
  end

  it 'should be persisted' do
    expect {
      is_expected.to eq(expected_response_status)
    }.to change{resource_class.count}.by(1)
  end

  it 'should return a serialized object' do
    is_expected.to eq(expected_response_status)
    expect(new_object).to be
    expect(response.body).to include(resource_serializer.new(new_object).to_json)
  end
end

shared_examples 'a viewable resource' do
  it 'should return a serialized resource' do
    is_expected.to eq(200)
    expect(response.status).to eq(200)
    expect(response.body).to be
    expect(response.body).not_to eq('null')
    expect(response.body).to eq(resource_serializer.new(resource).to_json)
  end
end

shared_examples 'an updatable resource' do
  before do
    expect(resource).to be_persisted
  end
  it 'should return success' do
    is_expected.to eq(200)
    expect(response.status).to eq(200)
    expect(response.body).to be
    expect(response.body).not_to eq('null')
  end
  it 'should persist changes to resource' do
    resource.reload
    original_attributes = resource.attributes
    expect {
      is_expected.to eq(200)
    }.not_to change{resource_class.count}
    resource.reload
    expect(resource.attributes).not_to eq(original_attributes)
    if original_attributes.has_key? "etag"
      expect(resource.etag).not_to eq(original_attributes["etag"])
    end
  end
  it 'should return a serialized resource' do
    is_expected.to eq(200)
    resource.reload
    expect(response.body).to include(resource_serializer.new(resource).to_json)
  end
end

shared_examples 'a removable resource' do
  let(:resource_counter) { resource_class }

  it 'should return an empty 204 response' do
    is_expected.to eq(204)
    expect(response.status).to eq(204)
    expect(response.body).not_to eq('null')
    expect(response.body).to be
  end
  it 'should remove the resource' do
    expect(resource).to be_persisted
    expect {
      is_expected.to eq(204)
    }.to change{resource_counter.count}.by(-1)
  end
end

shared_examples 'an authenticated resource' do
  include_context 'without authentication'

  it 'should return a 401 error response' do
    is_expected.to eq(401)
    expect(response.status).to eq(401)
  end
end

shared_examples 'an authorized resource' do
  it 'should return a 403 error response' do
    expect(resource_permission).to be_persisted
    expect(resource_permission.destroy!).to be_truthy
    expect(resource_permission).not_to be_persisted
    is_expected.to eq(403)
    expect(response.status).to eq(403)
  end
end

shared_examples 'a validated resource' do
  it 'returns a failed response' do
    is_expected.to eq(400)
    expect(response.status).to eq(400)
  end

  it 'returns errors as a JSON payload' do
    is_expected.to eq(400)
    expect(response.body).to be
    expect(response.body).not_to eq('null')

    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq('400')
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq('validation failed')
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq('Fix the following invalid fields and resubmit')
    expect(response_json).to have_key('errors')
    expect(response_json['errors']).to be_a(Array)
    expect(response_json['errors']).not_to be_empty
    response_json['errors'].each do |error|
      expect(error).to have_key('field')
      expect(error).to have_key('message')
    end
  end
end

shared_examples 'an identified resource' do
  it 'should return 404 with error when resource not found with id' do
    is_expected.to eq(404)
    expect(response.body).to be
    expect(response.body).not_to eq('null')
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq('404')
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq("#{resource_class} Not Found")
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq("you may have mistyped the #{resource_class} id")
  end
end

shared_examples 'a logically deleted resource' do
  let(:deleted_resource) { resource }
  it 'should return 404 with error when resource found is logically deleted' do
    expect(deleted_resource).to be_persisted
    expect(deleted_resource).to respond_to 'is_deleted'
    deleted_resource.update(is_deleted: true)
    is_expected.to eq(404)
    expect(response.body).to be
    expect(response.body).not_to eq('null')
    response_json = JSON.parse(response.body)
    expect(response_json).to have_key('error')
    expect(response_json['error']).to eq('404')
    expect(response_json).to have_key('reason')
    expect(response_json['reason']).to eq("#{deleted_resource.class.name} Not Found")
    expect(response_json).to have_key('suggestion')
    expect(response_json['suggestion']).to eq("you may have mistyped the #{deleted_resource.class.name} id")
  end
end
