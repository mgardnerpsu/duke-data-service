class Chunk < ActiveRecord::Base
  default_scope { order('created_at DESC') }
  audited
  after_save :update_upload_etag
  after_destroy :update_upload_etag

  belongs_to :upload
  has_one :storage_provider, through: :upload
  has_one :project, through: :upload
  has_many :project_permissions, through: :upload

  validates :upload_id, presence: true
  validates :number, presence: true
  validates :size, presence: true
  validates :fingerprint_value, presence: true
  validates :fingerprint_algorithm, presence: true

  delegate :project_id, to: :upload

  def http_verb
    'PUT'
  end

  def host
    storage_provider.url_root
  end

  def http_headers
    []
  end

  def object_path
    [upload_id, number].join('/')
  end

  def sub_path
    [project_id, object_path].join('/')
  end

  def expiry
    updated_at.to_i + storage_provider.signed_url_duration
  end

  def url
    storage_provider.build_signed_url(http_verb, sub_path, expiry)
  end

  private

  def update_upload_etag
    last_audit = self.audits.last
    new_comment = last_audit.comment ? last_audit.comment.merge({raised_by_audit: last_audit.id}) : {raised_by_audit: last_audit.id}
    self.upload.update(etag: SecureRandom.hex, audit_comment: new_comment)
    last_parent_audit = self.upload.audits.last
    last_parent_audit.update(request_uuid: last_audit.request_uuid)
  end
end
