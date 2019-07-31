# Genecode XY, crypting engine.
#
# The wise says:
# 	"This program is for you, those little nerds who want
# 	to explore the beautiful amount of uselessness of talking
# 	whith other little nerds like you in an imaginary language".
#
# Are you not convinced yet? Give it a try and have fun!
#
# The MIT License (MIT)
#
# Copyright (c) 2019 Elia Franzella
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "cli"

CodonStop   = %w[UAA UAG UGA]
CodonLett   = %w[C A T G U]
CodonRegl   = (CodonLett * 3).permutations(3).uniq.map(&.join) - CodonStop
EngineSize  = EngineChars.size
EngineChars = (" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]" +
               "^_`abcdefghijklmnopqrstuvwxyz{|}~¡«\n»¿ÀÁÈÉÌÍÒÓ×ÙÚàáèéìíòó÷ùú").chars
ProgramName = "Genecode XY"
Version     = "3.2.4-cr"
Logo        =
  "                                                       __
                                                      /\\ \\
      __       __     ___       __     ___     ___    \\_\\ \\      __
    /'_ `\\   /'__`\\ /' _ `\\   /'__`\\  /'___\\  / __`\\  /'_` \\   /'__`\\
   /\\ \\L\\ \\ /\\  __/ /\\ \\/\\ \\ /\\  __/ /\\ \\__/ /\\ \\L\\ \\/\\ \\L\\ \\ /\\  __/
   \\ \\____ \\\\ \\____\\\\ \\_\\ \\_\\\\ \\____\\\\ \\____\\\\ \\____/\\ \\___,_\\\\ \\____\\
    \\/___L\\ \\\\/____/ \\/_/\\/_/ \\/____/ \\/____/ \\/___/  \\/__,_ / \\/____/
      /\\____/                 __   __   __    __
      \\_/__/                 /\\ \\ /\\ \\ /\\ \\  /\\ \\
                             \\ `\\`\\/'/'\\ `\\`\\\\/'/
                              `\\/ > <   `\\ `\\ /'
                                 \\/'/\\`\\  `\\ \\ \\
                                 /\\_\\\\ \\_\\  \\ \\_\\
                                 \\/_/ \\/_/   \\/_/
"

Wtf = "%s is a command-line crypting tool developed in Crystal which turns texts into
DNA-RNA sections
You can use the command \"%s --encode \"text here\" \" to codify
an ordinary text, or decode DNA-RNA coded texts like \"TUAGUUUTUUGCGGUUTTACATUAUCAUCAATCUAA\".
More informations: https://en.wikipedia.org/wiki/RNA, https://en.wikipedia.org/wiki/DNA.\n
You will need a key to both encode or decode a text. Crypted texts have
unique key, of course, but you can choose one from 0 up to %d for encoding
with '--key' option or leave it random by omitting it.
\"%s --help\" might be helpful now ;)
Enjoy!" % [ProgramName, PROGRAM_NAME, EngineSize - 1, PROGRAM_NAME]

class String
  # Function to convert any sort of string into a coded string
  def gene_encode(key : Int32, fail_silently : Bool = false)
    unless fail_silently
      unless (errors = self.scan /.{0,2}[^#{EngineChars.join}\s]/).empty?
        raise ArgumentError.new \
          "Invalid characters for text to convert\nHere: %s" %
          errors.map { |e| e[0] + "<~ " }.join
      end
    end

    # ALGORITHM: cycle all codons rightwise *key* times
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

    # Appends one random CodonStop to output array
    output = output + CodonStop.sample unless output.empty?
    output
  end

  def gene_decode(key : Int32, fail_silently : Bool = false)
    unless fail_silently
      unless self =~ /(UAA|UAG|UGA)$/
        raise ArgumentError.new "Invalid format for DNA-RNA coded text: missing stop codon"
      end

      unless (errors = self.scan /.{0,2}[^#{CodonLett.join}\s]/).empty?
        raise ArgumentError.new(
          "Invalid format for DNA-RNA coded text\nHere: %s" %
          errors.map { |e| e[0] + "<~ " }.join
        )
      end
    end

    # REVERSE ALGORITHM: cycle all codons leftwise *key* times
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

class GenecodeCr < Cli::Command
  version "v%s Crystal" % Version

  class Options
    version desc: "Show %s version and quit" % ProgramName
    bool %w[-l --list], desc: "Shows allowed characters"
    bool %w[-w --what], desc: "Gene-what?? What the hell is this supposed to be?"
    bool %w[-e --encode], desc: "Encode texts in DNA-RNA form"
    bool %w[-d --decode], desc: "Decode DNA-RNA coded texts (key required)"
    bool %w[-u --unsafe], desc: "Disable and skip coding errors"
    help desc: "Show this help and quit"
    string %w[-k --key],
      desc: "Key used for encoding or decoding",
      default: "random"
    arg_array "text", desc: "STDIN is read if missing"
  end

  class Help
    title "Usage:\t#{PROGRAM_NAME} [-e|-d|-l|-u|-w] [-k <KEY>] [TEXT1 TEXT2 ...]"
    header <<-EOS
      E.g.:\t#{PROGRAM_NAME} --key 37 --encode "I'm a text" "Me too!"
      \t#{PROGRAM_NAME} --encode "I'm encoding with a random key!"
      \t#{PROGRAM_NAME} --decode -k 93 TUUGGUUACUACUTCAUTACAUGUUTCUTTUACGGTATCUGA
      EOS
    footer "(c) Elia Franzella - eliafranzella@hotmail.it"
  end

  def run
    raise ArgumentError.new "Encoding - Decoding conflict" if args.e? && args.d?

    if args.encode?
      if args.key == "random"
        key = rand(EngineSize)
        STDERR.puts "[key: %d]" % key
      else
        key = args.key.to_i % EngineSize
      end

      unless args.text.empty?
        args.text.each do |str|
          puts str.gene_encode key, args.u?
        end
      else
        puts stdin_read.gene_encode key, args.u?
      end
    end

    if args.decode?
      if args.key == "random"
        raise "Key is required for that option."
      else
        key = args.key.to_i % EngineSize
      end

      unless args.text.empty?
        args.text.each do |str|
          puts str.gene_decode key, args.u?
        end
      else
        puts stdin_read.gene_decode key, args.u?
      end
    end

    puts "Available characters:\n#{EngineChars}" if args.list?

    if args.what?
      print "%s\n\t\t-{%s %s | Author: Elia Franzella}-\n\n%s\n" % [
        Logo, ProgramName, Version, Wtf
      ]
    end
  end

  private def stdin_read
    out = ""
    while (in = gets(chomp: false)) != nil
      out = out + in unless in.nil?
    end
    out
  end
end

begin
  GenecodeCr.run ARGV
rescue err
  STDERR.puts "%s: %s" % [PROGRAM_NAME, err]
  exit 1
end
