require_relative 'base'
require 'pry'

# Initialize the API
service = Google::Apis::GmailV1::GmailService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# gets all messages
messages = []
next_page = nil
limit = 10
message_count = 0
begin
  result = service.list_user_messages('me', max_results: limit, page_token: next_page, q: 'in:spam')
  messages = result.messages
  next_page = result.next_page_token
  message_count += messages.count
  # binding.pry
end while next_page
print message_count.to_s

# puts "I have #{messages.count} number of messages"
# puts "Here are their subject lines"
# messages.each do | m |
#   get_message(m.id, service)
# end


# binding.pry