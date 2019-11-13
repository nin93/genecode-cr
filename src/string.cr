require "colorize"
require "./constants"
include Genecode::Constant

module Genecode
  class ::String
    # Converts a string into a coded string
    def gene_encode(key : Int32)
      # ALGORITHM: cycles all codons rightwise *key* times
      engine = CodonRegl.clone
      (key % EngineSize).times do
        engine.unshift(engine.pop)
      end

      # Iterative fetching right char to put into output
      output = ""
      self.each_char do |chr|
        imatch = EngineChars.index &.==(chr)
        output = output + engine[imatch] unless imatch.nil?
      end

      # Appends one random CodonStop to output string
      output = output + CodonStop.sample unless output.empty?
      output
    end

    # Reverts a string from a coded string
    def gene_decode(key : Int32)
      # REVERSE ALGORITHM: cycles all codons leftwise *key* times
      engine = EngineChars.clone
      (key % EngineSize).times do
        engine.push(engine.shift)
      end

      # Grouping condons by 3
      refined = self.scan(/\w{3}/).map(&.[0])
      output = ""

      refined.each do |cod|
        imatch = CodonRegl.index &.==(cod)
        output = output + engine[imatch] unless imatch.nil?
      end

      output
    end
  end
end
