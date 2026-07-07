# frozen_string_literal: true

module R2
  # Wraps an IO to render upload progress as it is read.
  #
  # Compatible with streaming uploads: the AWS SDK reads the body in
  # chunks, and each read advances the reported progress.
  class ProgressIO
    def initialize(io, total:, output: $stderr)
      @io = io
      @total = total
      @output = output
      @read = 0
    end

    def read(length = nil, outbuf = nil)
      @io.read(length, outbuf).tap do |chunk|
        next unless chunk

        @read += chunk.bytesize
        render
      end
    end

    def rewind
      @io.rewind
      @read = 0
    end

    def size
      @total
    end

    private

    def render
      percent = [(100.0 * @read / @total).floor, 100].min

      @output.print("\r[R2] uploading #{percent}%")
      @output.print("\n") if @read >= @total
      @output.flush
    end
  end
end
