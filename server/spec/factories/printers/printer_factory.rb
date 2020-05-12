require 'common'

module Sykus

  Factory.define Printers::Printer do |printer|
    printer.name 'printer%d'
    printer.url 'socket://10.42.20.%d'
    printer.driver 'someppd'
  end

end

