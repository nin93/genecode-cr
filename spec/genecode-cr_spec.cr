require "./spec_helper"

describe String do
  it "encodes regular text" do
    "Hello, world!".gene_encode(0).should contain \
      "ACGTCCGATGATGACCGACAGGGAGACGUAGATTCUCAT"
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
      EngineChars.join.gene_encode(i).gene_decode(i).should eq EngineChars.join
    end
  end

  it "encodes empty text" do
    EngineSize.times do |i|
      "".gene_encode(i).should eq ""
    end
  end

  it "decodes empty text" do
    EngineSize.times do |i|
      "".gene_decode(i).should eq ""
    end
  end

  it "skips unvalid characters" do
    EngineSize.times do |i|
      "u".gene_decode(i).should eq ""
      "AAAlua".gene_decode(i).size.should eq 1
    end
  end

  it "skips unvalid characters" do
    EngineSize.times do |i|
      "¢".gene_encode(i).should eq("")
      "valid¢".gene_encode(i).should contain "valid".gene_encode(i)[0..15]
    end
  end
end
