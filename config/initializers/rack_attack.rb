# Rate limiting configuration using rack-attack
# Prevents brute force attacks on authentication endpoints

class Rack::Attack
  # Throttle login endpoint - max 5 requests per minute per IP
  throttle('logins/ip', limit: 5, period: 60) do |req|
    if req.path == '/api/auth/login' && req.post?
      req.ip
    end
  end

  # Throttle login endpoint by email - max 5 requests per minute per email
  throttle('logins/email', limit: 5, period: 60) do |req|
    if req.path == '/api/auth/login' && req.post?
      req.params['email']
    end
  end

  # Throttle general API requests - max 100 requests per minute per IP
  throttle('api/ip', limit: 100, period: 60) do |req|
    if req.path.start_with?('/api')
      req.ip
    end
  end
end

# Return 429 (Too Many Requests) when throttled
Rack::Attack.throttled_responder = lambda do |env|
  [
    429,
    { 'Content-Type' => 'application/json' },
    [{ error: 'Too many requests. Please try again later.' }.to_json]
  ]
end

