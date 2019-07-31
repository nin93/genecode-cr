
# genecode-cr

Genecode XY is a command-line crypting tool developed in Crystal which turns texts into [DNA](https://en.wikipedia.org/wiki/DNA.)-[RNA](https://en.wikipedia.org/wiki/RNA) sections.
You can use the command `genecode-cr --encode "text here"` to codify an ordinary text, or decode DNA-RNA coded texts like "TUAGUUUTUUGCGGUUTTACATUAUCAUCAATCUAA".

You will need a key to both encode or decode a text. Crypted texts have unique key, of course, but you can choose one from 0 up to 121 for encoding with `--key` option or leave it random by omitting it.

The wise says:
  
  *"This program is for you, those little nerds who want*
  
  *to explore the beautiful amount of uselessness of talking*
  
  *whith other little nerds like you in an imaginary language"*.
  
  Are you not convinced yet? Give it a try and have fun!

## Installation

Install [crystal](https://crystal-lang.org/reference/installation) compiler.

Then:
```bash
git clone https://github.com/nin93/genecode-cr.git
cd genecode-cr
shards build --release
### Optional: your binary is in bin/
sudo cp ./bin/genecode-cr /usr/local/bin/
```

## Usage
```
genecode-cr [-e|-d|-l|-u|-w] [-k <KEY>] [TEXT1 TEXT2 ...]
```
Multiple text are allowed.
Standard input is read if no TEXT is given:
```
echo "foo" "bar" | genecode-cr -e -k 11

### Output:
# TATTUTTUTUTTTACTCTTTAGTAUAG
```

### Encoding

You can encode a text without specifying the key, genecode-cr will provide it in that case.
```
genecode-cr -e "I'm encoding with a random key!"

### Output:
# [key: 3]
# AGACAATTTUUTTUAGCATGGGCTTUCTTCGCATUTUUTGAGTTCGATTUUUUTTGUUUTGCGTGUGCATUCGCTTTTUUTTTGTUAGTAUUGUAA
```
Every ASCII printable character is allowed, even newline char. For complete list type `genecode-cr --list`. You can nevertheless go ahead and skip error parsing by including `--unsafe` option.

**NOTE**: key shows up in standard error output for reasons of clean input-output pipe.

### Decoding

You must provide a key in order to decode a text. 
```
genecode-cr -d -k 96 TUGACGUCUGGCGGCGUUACGGUAACGUCTGGCUGGUAG

### Output:
# I need a key
```
Here text format is highly restricted and so do the error parsing, but you won't worry about that if texts come out from genecode-cr itself.

```
genecode-cr -d -k 60 UGGCUUCUUCUUCopsCACCUUAG

### Output:
# genecode-cr: Invalid format for DNA-RNA coded text
# Here: UCo<~ ps<~
```
```
genecode-cr -d -k 60 UGGCUUCUUCUUCCACCUUAG

### Output:
# Uooops
```

You can still avoid this by including `--unsafe` option, but output might be broken: 
```
genecode-cr -d -k 60 UGGCUUCUUCUUCopsCACCUUAG -u

### Output:
# Uooos
```

## Contributing

1. Fork it (<https://github.com/nin93/genecode-cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Elia Franzella](https://github.com/nin93) - creator and maintainer
