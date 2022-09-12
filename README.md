# redmine_smime

Based on code from this blog post https://unboxed.co/blog/sending-smime-encrypted-emails-with-action-mailer/
Encrypts all outgoing e-mails using S/MIME. E-Mails without certificate will get a configurable warning e-mail instead.

## Instructions:
Create a directory called "certificates" in the redmine project root. In this directory, put the certificates for each user and the sender.
The sender of encrypted e-mails will be the e-mail defined in redmine setting "Emission email address" (Setting.mail_from)

Filenames for certificates should be "downcased-e-mail-address.cer" for the public certificates.
The sender certificate also needs a private key with the filename "downcased-e-mail-address.key"

Example:

User (recipient) has e-mail address "User1@Example.com":
- Certificate file: /usr/src/redmine/certificates/user1@example.com.cer



Setting.mail_from (sender) is "redmine-sender@example.com":
- Certificate file: /usr/src/redmine/certificates/redmine-sender@example.com.cer
- Private key file: /usr/src/redmine/certificates/redmine-sender@example.com.key
