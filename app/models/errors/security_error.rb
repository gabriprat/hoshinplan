module Errors
  class SecurityError < RuntimeError
    attr_reader :status
    attr_reader :code
    def initialize(code=401, status=401)
        super()
        @status = status
        @code = code
    end
  end
end