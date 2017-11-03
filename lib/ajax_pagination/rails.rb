require "will_paginate/view_helpers/action_view"

module AjaxPagination
  # A custom renderer class for WillPaginate that produces markup suitable for use with Twitter Bootstrap.
  class Rails < WillPaginate::ActionView::LinkRenderer
    include AjaxPagination::AjaxRenderer
  end
end