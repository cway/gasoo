#encoding: utf-8

module ApplicationHelper

  def to_bool( value )
    return value == 0 ? "否" : "是"
  end

end
