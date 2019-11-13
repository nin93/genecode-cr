module Genecode
  module Constant
    CodonLett   = %w[C A T G U]
    CodonStop   = %w[UAA UAG UGA]
    EngineSize  = EngineChars.size
    EngineChars = (" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]" +
                   "^_`abcdefghijklmnopqrstuvwxyz{|}~¡«\n»¿ÀÁÈÉÌÍÒÓ×ÙÚàáèéìíòó÷ùú").chars

    {% begin %}
      CodonRegl = [
        {% for l0 in %w[C A T G U] %}
          {% for l1 in %w[A U G C T] %}
            {% for l2 in %w[G T A U C] %}
              "{{l0.id}}{{l1.id}}{{l2.id}}",
            {% end %}
          {% end %}
        {% end %}
      ] - CodonStop
    {% end %}
  end

  module Exception
    class EDConflictError < ::Exception; end

    class KeyMissingError < ::Exception; end

    class InvalidCharError < ::Exception; end

    class InvalidCodonError < ::Exception; end

    class StopCodonMissingError < ::Exception; end
  end
end
