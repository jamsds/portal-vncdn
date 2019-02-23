class User < ApplicationRecord
	# Upload reseller logo
	has_attached_file :logo, {
		:default_url => ":attachment/null",
		s3_permissions: :private,
    :path => "/:class/:attachment/:filename"
	}
	do_not_validate_attachment_file_type :logo
	
	# Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable,

  has_one :credit, 			 dependent: :destroy
  has_one :subscription, dependent: :destroy

  has_one :notification, dependent: :destroy

  # Sync & Calculator Usage
  has_many :bandwidths
  has_many :storages
end