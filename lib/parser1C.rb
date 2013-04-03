#coding: utf-8
require 'rubygems'
require 'iconv'

class Parser1C

attr_reader :file_name, :file_path, :parameters, :accounts

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
@accounts = Hash.new     #рассчетные счета
@parameters = Hash.new   #Шапка с параметрами передачи и т.д.
converter= Iconv.new("UTF-8","WINDOWS-1251")
temporary_account = Hash.new #поглощает в себя секцию рассчетного счета
    #флаги секций
   in_acc_section = false #СекцияРасчСчет
   do_not_parse_header = false #пересекли ли мы хедер уже, флаг не дает затереть хедер дальнейшими директивами у каких совпадают имена
    #конец флагов секций   
File.open(@file_path, "r") do |input|
    input.each {|current_string_source|
    current_string = converter.iconv(current_string_source).strip
    
    if current_string.include?('=') #если происходит уравнение, значит мы внутри некоей секции или шапки, и получаем некие параметры 

      current_pair = current_string.split('=')
      req = current_pair.first.strip       
      req_value = current_pair.last.strip 
     
 
      #если мы в секции рассчетного счета
  if in_acc_section   
            case req
            when "ДатаНачала" then temporary_account[:interval_begin] = req_value
            when "ДатаКонца" then  temporary_account[:interval_end]   = req_value
            when "РасчСчет" then temporary_account[:number_acc] = req_value
            when "НачальныйОстаток" then temporary_account[:begin_cash] = req_value
            when "ВсегоПоступило" then temporary_account[:all_plus] = req_value
            when "ВсегоСписано" then temporary_account[:all_minus] = req_value
            when "КонечныйОстаток" then  temporary_account[:balance] = req_value
            end
        #конец варианта секции рассчетного счета
  elsif unless do_not_parse_header
  case req
      when "ВерсияФормата" then @parameters[:format_version] = req_value
      when "Кодировка"     then @parameters[:encoding] = req_value
      when "Получатель"    then @parameters[:recipient_program] = req_value  
      when "Отправитель"   then @parameters[:sender] = req_value
      when "ДатаСоздания"  then @parameters[:create_date] = req_value
      when "ВремяСоздания" then @parameters[:create_time] = req_value
      when "ДатаНачала"    then @parameters[:date_begin]  = req_value
      when "ДатаКонца"     then @parameters[:date_end] = req_value
      when "РасчСчет"      then @accounts[req_value.to_s] = {:accnum => req_value} 
        #строк РасчСчет может быть несколько, такая же встречается в секции СекцияРасчСчет, надо проверять флаг        
      end    
  end    
   end      

 else #если встречаем одиночные директивы секций     
      case current_string 
        when "СекцияРасчСчет" then in_acc_section = true
        when "КонецРасчСчет"  then in_acc_section = false        
      end       
      do_not_parse_header = true if current_string == "СекцияРасчСчет" #флаг чтобы хедер не перезаписывался
      #перебрасываем готовую секцию рассчетного счета если наткнулись на конец такой секции:      
      if current_string == "КонецРасчСчет"
      @accounts[temporary_account[:number_acc].to_s][:parameters] = Hash.new
      @accounts[temporary_account[:number_acc].to_s][:parameters] = temporary_account.clone                          
      temporary_account.clear #очищаем для страховки хеш чтобы старые данные не вкраплялись в новую секцию расс. счета                           
      end
end
}
end
end

def print_debug_state #отладочный метод
  
end


end