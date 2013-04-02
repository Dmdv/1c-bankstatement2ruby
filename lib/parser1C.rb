#coding: utf-8
require 'rubygems'
require 'iconv'

class Parser1C

attr_reader :file_name, :file_path, :format_version


@session_parameters = Array.new #общие параметры сессии, берутся из файла обмена
@docs = Array.new        #массив готовых. Каждый из них - хеш.  
@file_name = String.new  #имя входного файла
@file_path = String.new  #полный путь к файлу


def initialize(filename)
   @file_name = 'kl_to_1c.txt' #умолчание для файла - имя из спецификации 1С 
   @file_path = File.join(File.dirname( __FILE__ ), filename)
   if filename && File.exist?(@file_path) 
     @file_name = filename
   end
   parse()
end

def parse #здесь и происходит парсинг

converter= Iconv.new("UTF-8","WINDOWS-1251")
File.open(@file_path, "r") do |input|
    input.each {|current_string_source|
    current_string = converter.iconv(current_string_source)
    
    if current_string.include?('=')
      current_pair = current_string.split('=')
      req = current_pair.first.strip       
      req_value = current_pair.last.strip 
#      puts "Параметр #{req} равен #{req_value}"     
      case req
      when "ВерсияФормата" then @format_version = req_value
      when "Кодировка"     then @encoding = req_value
      when "Получатель"    then @recipient = req_value  
      when "Отправитель"   then @sender = req_value
      when "ДатаСоздания"  then @create_date = req_value
      when "ВремяСоздания" then @create_time = req_value
      when "ДатаНачала"    then @date_begin  = req_value
      when "ДатаКонца"     then @date_end = req_value        
      end 
    end 
    }
end
end

def format_valid? #проверяет 1 строку на валидность формату 1С по соглашению
  
end

end

