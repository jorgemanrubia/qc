module Qc
  class Backtest < Struct.new(:id, :name, :completed, :progress, :result, :success)
    alias success? success
    alias completed? completed

    def error?
      !success?
    end

    def progress_in_percentage
      progress * 100
    end
  end
end
