class CpController < ApplicationController
    def index
        @http_host = request.env["HTTP_HOST"]
    end
end
