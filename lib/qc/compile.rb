module Qc
  class Compile < Struct.new(:id, :state)
    def in_queue?
      state == 'InQueue'
    end

    def success?
      state == 'BuildSuccess'
    end

    def error?
      state == 'BuildError'
    end
  end
end
