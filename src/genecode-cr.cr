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
require "colorize"
require "./string"
require "./constants"

include Genecode
include Genecode::Constant
include Genecode::Exception

ProgramName = "Genecode XY"
Version     = "3.3.5-cr"
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

Wtf = "%s is a command-line Caesar Cipher developed in Crystal which turns texts into
DNA-RNA sections
You can use the command \"%s --encode \"text here\" \" to codify
an ordinary text, or decode DNA-RNA coded texts like \"TUAGUUUTUUGCGGUUTTACATUAUCAUCAATCUAA\".
More informations: https://en.wikipedia.org/wiki/RNA, https://en.wikipedia.org/wiki/DNA.\n
You will need a key to both encode or decode a text. Crypted texts have
unique key, of course, but you can choose one from 0 up to %d for encoding
with '--key' option or leave it random by omitting it.
\"%s --help\" might be helpful now ;)
Enjoy!" % [ProgramName, PROGRAM_NAME, EngineSize - 1, PROGRAM_NAME]

class Main < Cli::Command
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
    arg_array "text", desc: "standard input is read if missing"
  end

  class Help
    title "Usage:\t#{PROGRAM_NAME} [-l|-u|-w] [(-e|-d) [-k <KEY>] [TEXT1 TEXT2 ...]]"
    header <<-EOS
      E.g.:\t#{PROGRAM_NAME} --key 37 --encode "I'm a text" "Me too!"
      \t#{PROGRAM_NAME} --encode "I'm encoding with a random key!"
      \t#{PROGRAM_NAME} --decode -k 93 TCCGTUUUAUUAUGGACTAACUCCUGGUGCUUAGTAAUGCACUGA
      EOS
    footer "(c) Elia Franzella - eliafranzella@hotmail.it"
  end

  def run
    if args.e? && args.d?
      raise EDConflictError.new "Encoding - Decoding conflict"
    end

    if args.encode?
      text = unless args.text.empty?
        args.text.join '\n'
      else
        stdin_read
      end

      # Encoding errors handling
      unless args.unsafe?
        unless text.scan(/[^#{EngineChars.join}\\\s]/).empty?
          highlight = [] of Char | Colorize::Object(Char)

          text.each_char do |c|
            highlight << (c.to_s =~ /[#{EngineChars.join}\\\s]/ ? c : c.colorize :red)
          end

          raise InvalidCharError.new "Invalid characters for text to convert:\n%s" % highlight.join
        end
      end

      if args.key == "random"
        key = rand(EngineSize)
        STDERR.puts "[key: %d]" % key
      else
        key = args.key.to_i % EngineSize
      end

      puts text.gene_encode key
    end

    if args.decode?
      if args.key == "random"
        raise KeyMissingError.new "Key is required for that option."
      else
        key = args.key.to_i % EngineSize
      end

      text = unless args.text.empty?
        args.text.join '\n'
      else
        stdin_read
      end

      # Decoding errors handling
      unless args.unsafe?
        unless text =~ /^[ACGTU\s]*$/
          highlight = [] of Char | Colorize::Object(Char)

          text.each_char do |char|
            highlight << (char.to_s =~ /[ACGTU\s]/ ? char : char.colorize :red)
          end

          raise InvalidCodonError.new "Invalid format for DNA-RNA coded text:\n%s" % highlight.join
        end

        unless text =~ /(UAA|UAG|UGA)$/
          raise StopCodonMissingError.new "Invalid format for DNA-RNA coded text: missing stop codon"
        end
      end

      puts text.gene_decode key
    end

    if args.list?
      puts "Available characters:\n#{EngineChars}"
    end

    if args.what?
      print "%s\n\t\t-{%s %s | Author: Elia Franzella}-\n\n%s\n" % [
        Logo, ProgramName, Version, Wtf,
      ]
    end
  end

  private def stdin_read
    output = ""

    while (in_ = gets(chomp: false)) != nil
      unless in_.nil?
        output = output + in_
      end
    end

    output
  end
end

{% begin %}
  begin
    Main.run ARGV
{%
  errors = [
    [ArgumentError, 2],
    [EDConflictError, 8], [KeyMissingError, 9],
    [InvalidCharError, 16], [InvalidCodonError, 17], [StopCodonMissingError, 18],
  ]
%}

{% for error in errors %}
  rescue e : {{error[0].id}}
    STDERR.puts "%s: %s" % [PROGRAM_NAME, e]
    STDERR.puts "Program ended with exit code {{error[1].id}}"
    exit {{error[1].id}}
{% end %}
  end
{% end %}
