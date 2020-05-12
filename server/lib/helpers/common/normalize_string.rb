# encoding: utf-8
module Sykus

  # Normalizes a string.
  module NormalizeString

    # Removes whitespace, turns to lowercase and converts all non-ascii 
    # characters to their ascii-equivalent. Converts german umlauts correctly
    # to their two-character alternative.
    # @param [String] str Input string
    # @return [String] Output string
    def self.run(str)
      ActiveSupport::Inflector.transliterate(str.to_s).downcase.strip
    end

    private
    def self.store_translations
      I18n.locale = :de
      I18n.backend.store_translations(:de, i18n: { transliterate: { rule: {
        'ä' => 'ae',
        'ö' => 'oe',
        'ü' => 'ue',
        'Ä' => 'Ae',
        'Ö' => 'Oe',
        'Ü' => 'Ue',
      }}})

      # dummy call to load unicode tables on init, not on first call to #run 
      ActiveSupport::Inflector.transliterate 'x'
    end

    store_translations
  end

end

