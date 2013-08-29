#encoding: utf-8
#author cway 2013-07-18

module CategoryHelper 

  def get_name_path( ids_path ) 
    category_list     = Category.all_by_id_index
    name_path         = ""
    ids_path.split('/').each do |id|
      name_path      << category_list[id.to_i] << "/"
    end
    name_path
  end
end
