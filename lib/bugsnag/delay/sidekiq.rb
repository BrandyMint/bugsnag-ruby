module Bugsnag
  module Delay
    class Sidekiq
      include ::Sidekiq::Worker
      sidekiq_options Bugsnag.configuration.delay_with_sidekiq_options

      def perform(url, payload, configuration=Bugsnag.configuration, delivery_method=nil)

        # Sidekiq convert configuration object to the String ;(
        unless configuration.is_a? Bugsnag::Configuration
          configuration = Bugsnag.configuration
        end

        Bugsnag::Notification.deliver_exception_payload_without_sidekiq( url, payload, configuration, delivery_method )
      end
    end
  end
end

Bugsnag::Notification.class_eval do
  class << self
    def deliver_exception_payload_with_sidekiq(url, payload, configuration=Bugsnag.configuration, delivery_method=nil)
      Bugsnag::Delay::Sidekiq.perform_async(url, payload, configuration, delivery_method)
    end
  
    alias_method :deliver_exception_payload_without_sidekiq, :deliver_exception_payload
    alias_method :deliver_exception_payload, :deliver_exception_payload_with_sidekiq
  end
end
