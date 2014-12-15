#coding: utf-8
require 'rubygems'
require 'iconv'

class Parser1C

  attr_reader :file_name, :file_path, :parameters, :accounts, :documents

  @file_name = String.new  #имя входного файла
  @file_path = String.new  #полный путь к файлу
  @source_array_content = Array.new #исходный массив строк из файла данных

  def initialize(filename)
    read_and_get_content(filename) #читаем контент из файла внутрь массива source_array_content
    parse                #разбираем этот массив
  end

  def read_and_get_content(filename) #читает контент из файла в массив строк
    @file_path = File.join(File.dirname( __FILE__ ), filename)
    @file_name = filename if File.exist?(@file_path)
    @source_array_content = File.readlines(@file_path)
  end

  def parse #здесь и происходит парсинг

    @header_section_dictionary = {
        'ВерсияФормата' => :format_version,
        'Кодировка' => :encoding,
        'Отправитель' => :sender,
        'Получатель' => :recipient_program,
        'ДатаСоздания' => :create_date,
        'ВремяСоздания' => :create_time,
        'ДатаНачала' => :date_begin,
        'ДатаКонца' => :date_end,
        'РасчСчет' => :accnum
    }

    @acc_section_dictionary = {
        'ДатаНачала' => :interval_begin,
        'ДатаКонца' => :interval_end,
        'РасчСчет' => :number_acc,
        'НачальныйОстаток' => :begin_cash,
        'ВсегоПоступило' => :all_plus,
        'ВсегоСписано' => :all_minus,
        'КонечныйОстаток' => :balance
    }

    @document_section_dictionary = {
        'Дата' => :date,
        'Номер' => :doc_num,
        'Сумма' => :sum,
        'ПлательщикСчет' => :plat_acc,
        'ДатаСписано' => :date_sp,
        'ПлательщикРасчСчет' => :plat_r_acc,
        'ПлательщикБИК' => :plat_bik,
        'Плательщик' => :plat,
        'ПлательщикИНН' => :plat_inn,
        'ПлательщикКПП' => :plat_kpp,
        'Плательщик1' => :plat1,
        'ПлательщикБанк1' => :plat_bank1,
        'ПлательщикКорсчет' => :plat_corr_acc,
        'ПолучательСчет' => :pol_acc,
        'ДатаПоступило' => :date_delivery,
        'ПолучательРасчСчет' => :pol_r_acc,
        'ПолучательБИК' => :pol_bik,
        'Получатель' => :pol,
        'ПолучательИНН' => :pol_inn,
        'ПолучательКПП' => :pol_kpp,
        'Получатель1' =>   :pol1,
        'ПолучательБанк1' => :pol_bank1,
        'ПолучательКорсчет' => :pol_corr_acc,
        'ВидПлатежа' => :payment_type,
        'ВидОплаты' => :payment_type_plata,
        'СтатусСоставителя' => :state,
        'ПоказательКБК' => :kbk,
        'ОКАТО' => :okato,
        'ПоказательОснования' => :pok_osn,
        'ПоказательПериода' => :pok_period,
        'ПоказательНомера' => :pok_number,
        'ПоказательДаты' => :pok_date,
        'ПоказательТипа' => :pok_type,
        'СрокПлатежа' => :srok,
        'Очередность' => :stackposition,
        'НазначениеПлатежа' => :what_pay
    }

    @accounts = Array.new    #рассчетные счета
    @parameters = Hash.new   #Шапка с параметрами передачи и т.д.
    @documents = Array.new   #Документы

    converter = Iconv.new('UTF-8', 'WINDOWS-1251')
    temporary_account = Hash.new  #поглощает в себя секцию рассчетного счета
    temporary_document = Hash.new #поглощает в себя секцию документа

    #флаги секций
    in_acc_section = false      #СекцияРасчСчет
    in_document_section = false #Секция документа
    do_not_parse_header = false #пересекли ли мы хедер уже, флаг не дает затереть хедер дальнейшими директивами
    #конец флагов секций   

    @source_array_content.each {|current_string_source|
      current_string = converter.iconv(current_string_source).strip

      if current_string.include?('=') #если происходит уравнение, значит мы внутри некоей секции или шапки, и получаем некие параметры

        current_pair = current_string.split('=')
        req = current_pair.first.strip
        req_value = (current_pair.count == 1) ? nil : current_pair.last.strip #если пустое значение но оно указано в файле, делаем его nil

        #если мы в секции рассчетного счета
        if in_acc_section
          @acc_section_dictionary.each {|key,val|
            temporary_account[val] = req_value if req === key
          }
          #конец варианта секции рассчетного счета

          #если входим в секцию документа
        elsif !in_document_section && req == 'СекцияДокумент'
          temporary_document[:type] = req_value
          in_document_section = true
          #конец варианта входа в секцию документа

          #если мы внутри секции документа
        elsif in_document_section
          @document_section_dictionary.each { |key,val|
            temporary_document[val] = req_value if req === key
          }
          #конец варианта нахождения внутри секции документа


        elsif unless do_not_parse_header
                @header_section_dictionary.each { |key,val|
                  @parameters[val] = req_value if req === key
                }
              end
        end

      else #если встречаем одиночные директивы секций
        case current_string
          when 'СекцияРасчСчет' then in_acc_section = true
          when 'КонецРасчСчет' then in_acc_section = false
        end
        do_not_parse_header = true if current_string == 'СекцияРасчСчет' #флаг чтобы хедер не перезаписывался
        #перебрасываем готовую секцию рассчетного счета если наткнулись на конец такой секции:
        if current_string == 'КонецРасчСчет'
          @accounts << temporary_account.clone
          temporary_account.clear #очищаем для страховки хеш чтобы старые данные не вкраплялись в новую секцию расс. счета
        end

        if current_string == 'КонецДокумента' && in_document_section
          #перебрасываем готовый документ в хранилище, так как секция кончилась. Считаем ID документа его поле 'Номер'
          @documents << temporary_document.clone
          temporary_document.clear #очищаем во избежания затирания данных или замещения другими
          in_document_section = false #вышли из секции документа
        end

      end
    }
  end
end