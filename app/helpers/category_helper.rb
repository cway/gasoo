#encoding: utf-8
#author cway 2013-07-18

module CategoryHelper
  @@category_list = nil

  def get_name_path( ids_path )
    unless @@category_list
      @@category_list = Category.all_by_id_index
    end
    name_path         = ""
    ids_path.split('/').each do |id|
      name_path      << @@category_list[id.to_i] << "/"
    end
    
    return name_path
  end
end
