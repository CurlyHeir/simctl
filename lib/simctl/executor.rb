require 'json'
require 'open3'

module SimCtl
  class Executor
    class << self
      def execute(command)
        command = command.flatten.join(' ')
        Open3.popen2e(command) do |_, io, result|
          output = io.read
          raise StandardError.new(output) if result.value.to_i > 0
          return unless block_given?
          if looks_like_json?(output)
            yield JSON.parse(output)
          else
            yield output.chomp
          end
        end
      end

      private

      def looks_like_json?(output)
        output.start_with?('[') || output.start_with?('{')
      end
    end
  end
end