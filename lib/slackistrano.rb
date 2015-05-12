require 'slackistrano/version'
require 'net/http'
require 'json'

load File.expand_path("../slackistrano/tasks/slack.rake", __FILE__)

module Slackistrano

  #
  #
  #
  def self.post(team: nil, token: nil, webhook: nil, via_slackbot: false, payload: {})
    if via_slackbot
      post_as_slackbot(team: team, token: token, webhook: webhook, payload: payload)
    else
      post_as_webhook(team: team, token: token, webhook: webhook, payload: payload)
    end
  rescue => e
    puts "There was an error notifying Slack."
    puts e.inspect
  end

  #
  #
  #
  def self.post_as_slackbot(team: nil, token: nil, webhook: nil, payload: {})
    uri = URI(URI.encode("https://slack.com/api/chat.postMessage"))
    text = payload[:attachments].collect { |a| a[:text] }.join("\n")

    query = {
      :team => team,
      :token => token,
      :text => text,
      :channel => payload[:channel],
      :username => payload[:username]
    }

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(query)
      http.request request
    end
  end

  #
  #
  #
  def self.post_as_webhook(team: nil, token: nil, webhook: nil, payload: {})
    params = {'payload' => payload.to_json}

    if webhook.nil?
      webhook = "https://#{team}.slack.com/services/hooks/incoming-webhook"
      params.merge!('token' => token)
    end

    uri = URI(webhook)
    Net::HTTP.post_form(uri, params)
  end


end

