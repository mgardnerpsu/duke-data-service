class UserSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :display_name, :first_name, :last_name, :email

  def id
    object.uuid
  end
end