class ClientNotifier
  def notify(scan)
    project = scan.project
    body = scan.to_json(except: :project_id)
    Typhoeus.post(
      project.callback_url,
      body: body,
      headers: {
        "Content-Type" => "project/json",
        "User-Agent" => "VirusScanbot",
        "Auth-Key" => project.access_key_id,
        "Auth-Hash" => Digest::MD5.hexdigest("#{body}#{project.secret_access_key}")})
  end
end
