require "open3"
require "marcel"
require "pathname"
require "English"

class AvRunner
  def perform(scan)
    set_scan_file_attributes scan

    scan_results = scan.engines.inject({}) do |memo, engine|
      engine_class = "AvRunner::#{engine.to_s.camelize}".constantize
      memo[engine] = engine_class.new(scan).perform!
      memo
    end

    scan.av_checked! scan_results
  end

  private

  def set_scan_file_attributes(scan)
    md5 = Digest::MD5.file(scan.file_path).hexdigest
    sha1 = Digest::SHA1.file(scan.file_path).hexdigest
    sha256 = Digest::SHA256.file(scan.file_path).hexdigest
    file_size = File.size(scan.file_path)
    mime_type, mime_encoding = get_mimetype_and_encoding(scan.file_path)
    scan.update!(
      md5: md5,
      sha1: sha1,
      sha256: sha256,
      file_size: file_size,
      mime_type: mime_type,
      mime_encoding: mime_encoding
    )
  end

  def get_mimetype_and_encoding(filepath)
    filepath = validated_mimetype_path(filepath)

    # Keep libmagic-style charset output when available; Marcel only returns a content type.
    result = mimetype_from_file_command(filepath)
    return result.split(";").map(&:squish) if result.present?

    [
      Marcel::MimeType.for(Pathname.new(filepath), name: File.basename(filepath)),
      nil
    ]
  end

  def mimetype_from_file_command(filepath)
    stdout = IO.popen(["file", "--brief", "--mime", filepath], &:read)
    return nil unless $CHILD_STATUS.success?

    stdout.strip
  rescue Errno::ENOENT
    nil
  end

  def validated_mimetype_path(filepath)
    mimetype_path = File.expand_path(filepath)
    tmp_path = File.expand_path("tmp", Rails.root)
    return mimetype_path if mimetype_path.start_with?("#{tmp_path}#{File::SEPARATOR}")

    raise ArgumentError, "Invalid path"
  end
end
