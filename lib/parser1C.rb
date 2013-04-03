#coding: utf-8
require 'rubygems'
require 'iconv'

class Parser1C

  attr_reader :file_name, :file_path, :parameters, :accounts, :documents

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
@documents = Hash.new    #Документы

converter= Iconv.new("UTF-8","WINDOWS-1251")
temporary_account = Hash.new #поглощает в себя секцию рассчетного счета
temporary_document = Hash.new #поглощает в себя секцию документа

    #флаги секций
   in_acc_section = false      #СекцияРасчСчет
   in_document_section = false #Секция документа
   do_not_parse_header = false #пересекли ли мы хедер уже, флаг не дает затереть хедер дальнейшими директивами
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
      
      #если входим в секцию документа
      elsif !in_document_section && req == "СекцияДокумент"
      temporary_document[:type] = req_value
      in_document_section = true      
 
      #конец варианта входа в секцию документа
      
      #если мы внутри секции документа
      elsif in_document_section
        case req
        when "Дата"  then temporary_document[:date] = req_value
        when "Номер" then temporary_document[:doc_num] = req_value
        when "Сумма" then temporary_document[:sum] = req_value
        when "ПлательщикСчет" then temporary_document[:plat_acc] = req_value   
        when "ДатаСписано" then temporary_document[:date_sp] = req_value   
        when "ПлательщикРасчСчет" then temporary_document[:plat_r_acc] = req_value   
        when "ПлательщикБИК" then temporary_document[:plat_bik] = req_value   
        when "Плательщик" then temporary_document[:plat] = req_value
        when "ПлательщикИНН" then temporary_document[:plat_inn] = req_value   
        when "ПлательщикКПП" then temporary_document[:plat_kpp] = req_value   
        when "Плательщик1" then temporary_document[:plat1] = req_value     
        when "ПлательщикБанк1" then temporary_document[:plat_bank1] = req_value
        when "ПлательщикКорсчет" then temporary_document[:plat_corr_acc] = req_value
        when "ПолучательСчет" then temporary_document[:pol_acc] = req_value
        when "ДатаПоступило" then temporary_document[:date_delivery] = req_value
        when "ПолучательРасчСчет" then temporary_document[:pol_r_acc] = req_value
        when "ПолучательБИК" then temporary_document[:pol_bik] = req_value      
        when "Получатель" then temporary_document[:pol] = req_value
        when "ПолучательИНН" then temporary_document[:pol_inn] = req_value
        when "ПолучательКПП" then temporary_document[:pol_kpp] = req_value
        when "Получатель1" then temporary_document[:pol1] = req_value
        when "ПолучательБанк1" then temporary_document[:pol_bank1] = req_value
        when "ПолучательКорсчет" then temporary_document[:pol_corr_acc] = req_value
        when "ВидПлатежа" then temporary_document[:payment_type] = req_value
        when "ВидОплаты" then temporary_document[:payment_type_plata] = req_value
        when "СтатусСоставителя" then temporary_document[:state] = req_value
        when "ПоказательКБК" then temporary_document[:kbk] = req_value
        when "ОКАТО" then temporary_document[:okato] = req_value
        when "ПоказательОснования" then temporary_document[:pok_osn] = req_value
        when "ПоказательПериода" then temporary_document[:pok_period] = req_value
        when "ПоказательНомера" then temporary_document[:pok_number] = req_value
        when "ПоказательДаты" then temporary_document[:pok_date] = req_value  
        when "ПоказательТипа" then temporary_document[:pok_type] = req_value 
        when "СрокПлатежа" then temporary_document[:srok] = req_value
        when "Очередность" then temporary_document[:stackposition] = req_value
        when "НазначениеПлатежа" then temporary_document[:what_pay] = req_value
        end
      #конец варианта нахождения внутри секции документа  
      
        
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
    
    if current_string == "КонецДокумента" && in_document_section
       #перебрасываем готовый документ в хранилище, так как секция кончилась. Считаем ID документа его поле "Номер"
       @documents[temporary_document[:doc_num].to_s] = Hash.new
       @documents[temporary_document[:doc_num].to_s][:parameters] = Hash.new
       @documents[temporary_document[:doc_num].to_s][:parameters] = temporary_document.clone
       temporary_document.clear #очищаем во избежания затирания данных или замещения другими        
       in_document_section = false #вышли из секции документа
     end
     
   end
 }
end
end

def print_debug_state #отладочный метод
  
end


end