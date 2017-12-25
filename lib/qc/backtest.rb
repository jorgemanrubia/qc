module Qc
  class Backtest < Struct.new(:id, :name, :completed, :progress, :result, :success)
    alias success? success

    def error?
      !success?
    end

    def started?
      progress > 0
    end

    def completed?
      completed && (error? || (success? && result && result['TotalPerformance']))
    end

    def to_s
      description = "Backtest #{id}"
      return "Backtest #{id} (not finished)" unless completed?
      statistics = result['TotalPerformance']['PortfolioStatistics']
      max_length = statistics.collect {|key, value| key.length}.max

      description << "\n\n"
      statistics.each do |key, value|
        formatted_key = "#{key}: #{' ' * (max_length - key.length)}"
        description << "#{formatted_key}#{value}\n"
      end

      description
    end
  end
end
