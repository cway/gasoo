class  TestController < ApplicationController

  #1169 
  def get_hash( len )
    chars          = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass        = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end

  #33
  def index
    start              = Time.now.to_i
    list               = Array.new
    (1..100000).each do |i|
      obj              = Hash.new
      obj['name']      = get_hash 20
      obj['desc']      = get_hash 102
      obj['timestamp'] = Time.now.to_i
      obj['is_active'] = 0
      #list << obj
      Test.create( obj )
    end
    #Test.create list
    duration           = Time.now.to_i - start
    render :json      => duration 
  end 

  def get_data_test
    start              = Time.now.to_i
    data               = Test.where( { is_active: 0 })
    data.each do |piece|
      puts piece.to_json
    end 
    duration           = Time.now.to_i - start
    render :json      => duration 
  end
end
