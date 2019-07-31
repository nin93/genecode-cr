require "./spec_helper"

describe String do
  it "encodes regular text" do
    "Hello, world!".gene_encode(0).should contain \
      "AUCTUUGCTGCTGCGCGUCATGTUGCGGAUGCTTUTCAG"
  end

  it "encodes regularly in all keys" do
    EngineSize.times do |i|
      "Hello, world!".gene_encode(i).should match /[ACGTU]/
    end
  end

  it "encodes regularly in all keys" do
    EngineSize.times do |i|
      "Hello, world!".gene_encode(i).size.should eq("Hello, world!".size * 3 + 3)
    end
  end

  it "encodes self into rna-dna and decodes it back" do
    EngineSize.times do |i|
      "Hello, world!".gene_encode(i).gene_decode(i).should eq("Hello, world!")
    end
  end

  it "encodes empty text" do
    "".gene_encode(0).should eq("")
  end

  it "raises ArgumentError if text to encode has unvalid chars" do
    expect_raises ArgumentError do
      "¢".gene_encode(0)
    end
  end

  it "raises ArgumentError if rna-dna coded text has unvalid format" do
    expect_raises ArgumentError do
      "SUCAUGA".gene_decode(0)
    end
  end

  it "raises ArgumentError if rna-dna coded text has not a stop codon" do
    expect_raises ArgumentError do
      "SUCA".gene_decode(0)
    end
  end
end
