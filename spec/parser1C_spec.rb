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
      parser.format_version.should be_false
    #этот тест специально сделан непроходимым. Нужен способ как выяснить подается ли пустая строка или Nil
    #в ожидателе
    end
  end

end