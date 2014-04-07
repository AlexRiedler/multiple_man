require 'bunny'
require 'connection_pool'
require 'active_support/core_ext/module'

module MultipleMan
  class Connection
    def self.connection
      @connection ||= begin
        connection = Bunny.new(MultipleMan.configuration.connection)
        MultipleMan.logger.debug "Connecting to #{MultipleMan.configuration.connection}"
        connection.start
        connection
      end
    end

    def self.channel_pool
      @channel_pool ||= ConnectionPool.new(size: 25, timeout: 5) { connection.create_channel }
    end

    def self.connect
      channel_pool.with do |channel|
        yield new(channel) if block_given?
      end
    end

    def initialize(channel)
      self.channel = channel
    end

    def topic
      @topic ||= channel.topic(topic_name)
    end

    def topic_name
      MultipleMan.configuration.topic_name
    end

    delegate :queue, to: :channel
    
  private

    attr_accessor :channel

  end

  class ListenerConnection < Connection
    def self.channel_pool
      @channel_pool ||= ConnectionPool.new(size: 1, timeout: 5) { connection.create_channel(nil, MultipleMan.configuration.worker_concurrency) }
    end
  end
end