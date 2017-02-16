class Auth::Crowd

  def self.login (username, password)
    uri = URI.parse("http://localhost:8095")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new("/crowd/rest/usermanagement/1/authentication?username=" + username)
    request.basic_auth 'docker', 'docker'
    request.add_field('Accept', 'application/json')
    request.add_field('Content-Type', 'application/json')
    request.body = {'value' => password}.to_json
    response = http.request(request)

    result = JSON.parse(response.read_body)
    if response.code != '200'
      raise result['message']
    end

    raise 'User not active' if !result['active']

    user = {
      username: result['name'],
      email: result['email'],
      name: result['display-name']
    }

    return User.from_crowd(user)
  end
end
