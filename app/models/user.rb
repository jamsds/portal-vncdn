class User < ApplicationRecord
  # Remove Reseller Logo
  before_save :destroy_attachment?

	# Upload reseller logo
	has_attached_file :logo, {
		:default_url => ":attachment/null",
		s3_permissions: :private,
    :path => "/:class/:attachment/:filename",
    validate_media_type: false
	}
  validates_attachment_file_name :logo, :matches => [/png\Z/, /jpe?g\Z/, /svg\Z/]
	
	# Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  has_one :credit, 			 dependent: :destroy
  has_one :subscription, dependent: :destroy

  has_one :notification, dependent: :destroy

  # Sync & Calculator Usage
  has_many :bandwidths
  has_many :storages
  
  # Delete logo
  def attachment_delete
    @attachment_delete ||= "0"
  end

  def attachment_delete=(value)
    @attachment_delete = value
  end

  private
    def destroy_attachment?
      self.logo.clear if @attachment_delete == "1"
      self.domain.clear if @attachment_delete == "1"
      self.color.clear if @attachment_delete == "1"
    end
end