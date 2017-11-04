module Qc
  class QuantConnectProxy
    attr_reader :credentials

    def initialize(credentials)
      @credentials = credentials
    end
  end
end
