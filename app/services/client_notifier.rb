class ClientNotifier
  def notify(scan)
    project = scan.project
    body = scan.to_json(except: :project_id)
    request = Typhoeus::Request.new(
      project.callback_url,
      method: :post,
      body: body,
      ssl_verifypeer: false,
      ssl_verifyhost: 0, # host checking disabled
      headers: {
        "Content-Type" => "application/json",
        "User-Agent" => "Vigilion",
        "X-Api-Key" => project.access_key_id,
        "X-Request-Signature" => Digest::MD5.hexdigest("#{body}#{project.secret_access_key}")
      }
    )
    request.on_complete do |response|
      if response.success?
        webhook_response = response.body
      elsif response.timed_out?
        webhook_response = "Error: timeout"
      elsif response.code == 0
        webhook_response = "Error: #{response.return_message}"
      else
        webhook_response = "Error: #{response.code.to_s}"
      end
      scan.update!(webhook_response: webhook_response)
    end
    request.run
  end
end
