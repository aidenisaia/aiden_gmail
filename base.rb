require 'pry'
require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = "Aiden's gmail ruby code".freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

def get_message(id, service)
  result = service.get_user_message('me', id)
  payload = result.payload
  headers = payload.headers

  date = headers.any? { |h| h.name == 'Date' } ? headers.find { |h| h.name == 'Date' }.value : ''
  from = headers.any? { |h| h.name == 'From' } ? headers.find { |h| h.name == 'From' }.value : ''
  to = headers.any? { |h| h.name == 'To' } ? headers.find { |h| h.name == 'To' }.value : ''
  subject = headers.any? { |h| h.name == 'Subject' } ? headers.find { |h| h.name == 'Subject' }.value : ''

  body = payload.body.data
  if body.nil? && payload.parts.any?
    body = payload.parts.map { |part| 
      if not part.body.data.nil?
        part.body.data
      elsif not part.parts.nil?
        part.parts.map { |part| 
          part.body.data 
        }.join
      end 
    }.join
  end

 #  puts "id: #{result.id}"
 #  puts "date: #{date}"
 #  puts "from: #{from}"
 #  puts "to: #{to}"
 #  puts "subject: #{subject}"
 # # puts "body: #{body}"
 return {
  id: result.id, 
  date: date,
  from: from,
  to: to,
  subject: subject,
  body: body.force_encoding("UTF-8")
 }
end

