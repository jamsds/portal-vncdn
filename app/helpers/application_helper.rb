module ApplicationHelper
	def accountType(id)
    case id
      when 1
        'Customer'
      when 2
        'Reseller'
    end
  end

  def subscriptionType(id)
  	case id
      when 1
        'Free'
      when 2
        'Credit'
      when 3
        'Monthly'
    end
  end
end
