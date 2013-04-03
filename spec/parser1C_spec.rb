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
        }
      
      puts "###################################################################"
    end
  end

end