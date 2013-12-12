json.array!(@users) do |user|
  json.extract! user, :id, :user_email, :access_token, :refresh_token
  json.url user_url(user, format: :json)
end
