module MultipleMan
  module Publisher
    def Publisher.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def publish(options = {})
        MultipleMan.logger.info("Setting up publish for #{self.name}")
        after_commit ModelPublisher.new(:create, options), on: :create
        after_commit ModelPublisher.new(:update, options), on: :update
        after_commit ModelPublisher.new(:destroy, options), on: :destroy
      end
    end
  end
end