require 'net/http'
require 'json'
require 'uri'

def get_topic_count(topic)
  url = "https://en.wikipedia.org/w/api.php?action=parse&section=0&prop=text&format=json&page=#{topic}"
  uri = URI(url)

  response = Net::HTTP.get(uri)
  data = JSON.parse(response)

  text_html = data['parse']['text']['*']
  count = 0
  return count if text_html.empty?

  while text_html.include?(topic)
    count += 1
    text_html.sub!(topic, '')
  end
  count
end

pp get_topic_count('pizza')
