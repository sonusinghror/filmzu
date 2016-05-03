module HomeHelper
  def resource_name
    :filmmaker
  end
  
  def resource_class
    "User".constantize
  end
   
  def resource
    @resource ||= Filmmaker.new
  end
   
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:filmmaker]
  end
end
