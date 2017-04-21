class FayeCommentControllerHelper
  include ActionView::Helpers::DateHelper
  include Rails.application.routes.url_helpers

  def run(c)
    begin
      Rails.logger.debug "FAYECOMMENT: helper running! "
      model_name = c.type.sub('Comment','').downcase
      id = c.public_send("#{model_name}_id")
      link = url_for(c.creator)
      message = {
          typed_id: c.typed_id,
          body: c.body,
          created_at: c.created_at,
          creator_id: c.creator_id,
          creator_name: c.creator.name,
          creator_link: link,
          created_at_ago: I18n.t('comments.ago', {ago: time_ago_in_words(c.created_at)})
      }
      Rails.logger.debug "FAYECOMMENT PUBLISH TO: /comment/#{model_name.pluralize}/#{id} -- #{message.inspect}"
      FayeCommentController.publish("/comment/#{model_name.pluralize}/#{id}", message)
    rescue Exception => e
      Rails.logger.error "FAYECOMMENT ERROR: " + e.message + "\n\n"
      Rails.logger.error e.backtrace.join("\n\t")
    end
  end
end


class FayeCommentController < FayeRails::Controller
  observe GenericComment, :after_create do |c|
    Rails.logger.debug "FAYECOMMENT: Generic comment created! "
    FayeCommentControllerHelper.new.run(c)
  end
end