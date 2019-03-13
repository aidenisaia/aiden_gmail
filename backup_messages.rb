require_relative 'base'
require 'pry'
require 'json'

# Initialize the API
service = Google::Apis::GmailV1::GmailService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# gets all messages
messages = []
next_page = nil
limit = 13
message_hashes = []

begin 
  
  # fetch first page of messages   
  result = service.list_user_messages('me', max_results: limit, page_token: next_page, q: 'label:inbox')
  messages = result.messages
  next_page = result.next_page_token
  threads = []

  # for each message
  messages.each do | m |

    # fetch message - fire threads concurrently
    threads << Thread.new do
      message_hash = get_message(m.id, service)
    end
    print '.'
  end

  # wait for all threads to return
  message_hashes += threads.map(&:value)

end while next_page

# save to a json file
File.open("temp.json","w") do |f|
  f.write(message_hashes.to_json)
end

#binding.pry