class CpController < ApplicationController
    layout "main"
    def index
        @http_host = request.env["HTTP_HOST"]
    end
end
