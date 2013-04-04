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
    it 'Рассчетный счет должен быть взят в количестве 1' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.accounts.count.should == 1           
    end

    it 'Документы должны быть взяты в количестве 2 штуки' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.documents.count.should == 2           
    end

    it 'Номер первого документа должен присутвовать и соответствовать данным' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.documents[0][:doc_num].should == "123456"       
    end

     it 'Номер второго документа должен присутвовать и соответствовать данным' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.documents[1][:doc_num].should == "123457"       
    end

    it 'Баланс рассчетного счета должен браться правильно' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.accounts[0][:balance].should == "90001.00"           
    end  

    it 'Параметры у каких пустое значение, должны быть в структуре, но иметь значение nil' do
      parser = Parser1C.new('1c_format_demo.txt')
      parser.documents[0][:okato].should be_nil
    end  
  end  

end