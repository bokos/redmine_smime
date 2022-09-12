require 'openssl'

class EmailPatch
  class << self
    include OpenSSL

    def delivering_email(message)
      encrypted_message = sign_and_encrypt(message.encoded, message.to.concat(message.bcc||[]))
      if encrypted_message === false
        warn_message_body = Setting.plugin_redmine_smime[:certificate_not_available_message_body]
        message.body = warn_message_body
        message.from = "#{Setting.plugin_redmine_smime[:certificate_not_available_message_sender_name]} <#{Setting.mail_from.downcase}>"
        message.subject = Setting.plugin_redmine_smime[:certificate_not_available_message_subject]
        message.parts.each do |part|
          part.body = warn_message_body
        end
        return
      end
      overwrite_body(message, encrypted_message)
      overwrite_headers(message, encrypted_message)
    end

    private

    def sign_and_encrypt(data, recipients)
      certificates = certificates_for(recipients)
      return false if certificates.nil?
      return false if certificates.any? {|cert| cert.not_after.to_datetime < DateTime.now }
      encrypt(sign(data), certificates)
    end

    def sign(data)
      PKCS7.write_smime(PKCS7.sign(certificate, private_key, data, [], PKCS7::DETACHED))
    end

    def encrypt(data, certificates)
      Mail.new(PKCS7.write_smime(PKCS7.encrypt(certificates, data, cipher)))
    end

    def cipher
      @cipher ||= Cipher.new('AES-256-CBC')
    end

    def certificate
      @certificate ||= X509::Certificate.new(File.read(certificate_path))
    end

    def certificate_path
      Rails.root.join('certificates', "#{Setting.mail_from.downcase}.cer")
    end

    def private_key
      @private_key ||= PKey::RSA.new(File.read(private_key_path))
    end

    def private_key_path
      Rails.root.join('certificates', "#{Setting.mail_from.downcase}.key")
    end

    def certificates_for(recipients)
      begin
        recipients.map do |recipient|
          cert_path = certificate_path_for(recipient)
          return nil unless File.file?(cert_path)
          cert_file = File.read(cert_path)
          X509::Certificate.new(cert_file)
        end
      rescue OpenSSL::X509::CertificateError
        nil
      end
    end

    def certificate_path_for(recipient)
      Rails.root.join('certificates', "#{recipient.downcase}.cer")
    end

    def overwrite_body(message, encrypted_message)
      message.body = nil
      message.body = encrypted_message.body.encoded
    end

    def overwrite_headers(message, encrypted_message)
      message.content_disposition = encrypted_message.content_disposition
      message.content_transfer_encoding = encrypted_message.content_transfer_encoding
      message.content_type = encrypted_message.content_type
    end
  end
end
