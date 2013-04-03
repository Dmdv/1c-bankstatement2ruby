require 'spec_helper'
require 'lib/parser1C'

describe Parser1C do

  context "Корректность класса и входной файл" do
    it 'получение экземпляра класса' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.should be_an_instance_of Parser1C
    end

    it 'входной файл должен существовать, и быть принят парсером' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.file_name.should == '1c_format_demo.txt'
    end

    it 'входной файл должен быть доступен для чтения' do
      parser = Parser1C.new('1c_format_demo.txt')
      File.readable?(parser.file_path).should be_true
    end
  end

  context "Наличие обязательных параметров формата обмена" do
    it 'Версия формата обязательна' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.parameters[:format_version].should_not == "" 
    end
       it 'Кодировка обязательна' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.parameters[:encoding].should_not == ""      
    end
         it 'Программа - получатель обязательна' do
      parser = Parser1C.new('1c_format_demo.txt')      
      parser.parameters[:recipient_program].should_not == ""      
    end
  end
  
  context "Правильность логики парсинга" do
    it 'Баланс рассчетного счета должен браться' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.accounts["10203450600780000090"][:parameters][:balance].should == "90001.00"     
    end  
  end

  context "Отладочный вывод информации для сверки" do
    it "Выводим информацию о документе" do
      parser = Parser1C.new('1c_format_demo.txt')
      puts "###################################################################"
      puts "Номер версии формата обмена : #{parser.parameters[:format_version]}"
      puts "Кодировка файла :             #{parser.parameters[:encoding]}"
      puts "Программа-получатель :        #{parser.parameters[:recipient_program]}"
      puts "Отправитель :                 #{parser.parameters[:sender]}"
      puts "Дата формирования файла  :    #{parser.parameters[:create_date]}"
      puts "Время формирования файла :    #{parser.parameters[:create_time]}"
      puts "Дата начала интервала    :    #{parser.parameters[:date_begin]}"
      puts "Дата конца интервала     :    #{parser.parameters[:date_end]}"
      puts ""
      
      parser.accounts.keys.each { |key|
        puts "Присутствует рассчетный счет : #{key}"
        puts "--------------------------счет #{key}----------------------------"
        puts "Дата начала интервала :              #{parser.accounts[key.to_s][:parameters][:interval_begin]}" 
        puts "Дата конца  интервала :              #{parser.accounts[key.to_s][:parameters][:interval_end]}"
        puts "Начальный остаток :                  #{parser.accounts[key.to_s][:parameters][:begin_cash]}"
        puts "Обороты входящих платежей :          #{parser.accounts[key.to_s][:parameters][:all_plus]}"
        puts "Обороты исходящих платежей :         #{parser.accounts[key.to_s][:parameters][:all_minus]}"
        puts "Конечный остаток :                   #{parser.accounts[key.to_s][:parameters][:balance]}"
        puts "---------------------конец счета #{key}--------------------------"
        puts ""
        }
        
      parser.documents.keys.each { |key|
        puts "Присутствует документ номер : #{key}"
        puts ""
        puts "--------------------------Документ #{key}----------------------------"
        puts "Вид документа :              #{parser.documents[key.to_s][:parameters][:type]}" 
        puts "Номер документа :            #{parser.documents[key.to_s][:parameters][:doc_num]}"
        puts "Дата документа :             #{parser.documents[key.to_s][:parameters][:date]}"
        puts "Сумма платежа :              #{parser.documents[key.to_s][:parameters][:sum]}"
        puts "Расчетный счет плательщика : #{parser.documents[key.to_s][:parameters][:plat_acc]}"
        puts "Дата списания средств с р/с: #{parser.documents[key.to_s][:parameters][:date_sp]}"
        puts "Расчетный счет плательщика:  #{parser.documents[key.to_s][:parameters][:plat_r_acc]}"
        puts "БИК банка плательщика:       #{parser.documents[key.to_s][:parameters][:plat_bik]}"
        puts "Плательщик:                  #{parser.documents[key.to_s][:parameters][:plat]}"
        puts "ИНН плательщика              #{parser.documents[key.to_s][:parameters][:plat_inn]}"
        puts "КПП плательщика              #{parser.documents[key.to_s][:parameters][:plat_kpp]}"
        puts "Наименование плательщика, стр.1: #{parser.documents[key.to_s][:parameters][:plat1]}"
        puts "Банк плательщика             #{parser.documents[key.to_s][:parameters][:plat_bank1]}"
        puts "Корсчет банка плательщика    #{parser.documents[key.to_s][:parameters][:plat_corr_acc]}"
        puts "Расчетный счет получателя    #{parser.documents[key.to_s][:parameters][:pol_acc]}"
        puts "Дата поступления средств на р/с #{parser.documents[key.to_s][:parameters][:date_delivery]}"
        puts "Расчетный счет получателя    #{parser.documents[key.to_s][:parameters][:pol_r_acc]}"
        puts "БИК банка получателя         #{parser.documents[key.to_s][:parameters][:pol_bik]}"
        puts "Получатель                   #{parser.documents[key.to_s][:parameters][:pol]}"
        puts "ИНН получателя               #{parser.documents[key.to_s][:parameters][:pol_inn]}"
        puts "КПП получателя               #{parser.documents[key.to_s][:parameters][:pol_kpp]}"
        puts "Наименование получателя      #{parser.documents[key.to_s][:parameters][:pol1]}"
        puts "Банк получателя              #{parser.documents[key.to_s][:parameters][:pol_bank1]}"
        puts "Корсчет банка получателя     #{parser.documents[key.to_s][:parameters][:pol_corr_acc]}"
        puts "Вид платежа                  #{parser.documents[key.to_s][:parameters][:payment_type]}"
        puts "Вид оплаты (вид операции)    #{parser.documents[key.to_s][:parameters][:payment_type_plata]}"
        puts "Статус составителя расчетного документа  #{parser.documents[key.to_s][:parameters][:state]}"
        puts "Показатель кода бюджетной классификации  #{parser.documents[key.to_s][:parameters][:kbk]}"
        puts "ОКАТО                        #{parser.documents[key.to_s][:parameters][:okato]}"
        puts "Показатель основания налогового платежа #{parser.documents[key.to_s][:parameters][:pok_osn]}"
        puts "Показатель налогового периода / Код таможенного органа #{parser.documents[key.to_s][:parameters][:pok_period]}"
        puts "Показатель номера документа  #{parser.documents[key.to_s][:parameters][:pok_number]}"
        puts "Показатель даты документа    #{parser.documents[key.to_s][:parameters][:pok_date]}"
        puts "Показатель типа платежа      #{parser.documents[key.to_s][:parameters][:pok_type]}"
        puts "Срок платежа (аккредитива)   #{parser.documents[key.to_s][:parameters][:srok]}"
        puts "Очередность платежа          #{parser.documents[key.to_s][:parameters][:stackposition]}"
        puts "Назначение платежа           #{parser.documents[key.to_s][:parameters][:what_pay]}"
        puts "---------------------конец документа #{key}--------------------------"
        puts ""
        puts ""
        }   
      
      puts "###################################################################"
    end
  end

end