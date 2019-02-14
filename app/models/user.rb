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
         :recoverable, :rememberable, :trackable, :validatable
end