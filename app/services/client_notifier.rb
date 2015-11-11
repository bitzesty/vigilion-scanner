class ClientNotifier
  def notify(scan)
    project = scan.project
    body = scan.to_json(except: :project_id)
    Typhoeus.post(
      project.callback_url,
      body: body,
      ssl_verifypeer: false,
      ssl_verifyhost: 0, # host checking disabled
      headers: {
        "Content-Type" => "application/json",
        "User-Agent" => "Vigilion",
        "X-Api-Key" => project.access_key_id,
        "Auth-Hash" => Digest::MD5.hexdigest("#{body}#{project.secret_access_key}")})
  end
end
