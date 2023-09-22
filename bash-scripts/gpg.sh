#!/bin/bash

gpg --version

# generate new key (use correct name, e-mail address,4096 key size AND A VERY STRONG PASSWORD):
gpg --full-generate-key
gpg --output gpg-revoke-user.asc --gen-revoke user@gmail.com
gpg --list-keys
gpg --list-keys "user@gmail.com" | grep pub -A 1 | grep -v pub
gpg --armor --export A11343DDDDDDD  > user-public-key.gpg
gpg --keyserver pgp.mit.edu --send-keys A11343DDDDDDD
gpg --keyserver pgp.mit.edu --search-keys reader@linoxide.com
gpg --keyserver pgp.mit.edu --recv-keys  D4535DDDDDDD
gpg --import user-public-key.gpg
gpg --sign-key A11343D89CE
gpg --encrypt --armor --recipient user@gmail.com file_name

# encrypt a file for a "destination" person with signin,
# this means both persons exchanged and imported their public keys in advanced.
# you can use multiple --recipient parameters to send to multiple destination
gpg --sign --encrypt --armor --recipient user@gmail.com file_pub_sign
gpg --multifile --encrypt --armor --recipient user@gmail.com file1 file2
gpg --encrypt-files --armor --recipient user@gmail.com file1 file2


gpg --decrypt file_pub.asc --output decrypted_file
gpg --decrypt-files course.asc car.asc


gpg --fingerprint public-key.gpg
# FYI: *.asc is encrypted with the armored option and *.gpg are gpg binary files without armored option


gpg --delete-secret-key KEY_ID
gpg --delete-secret-keys username
gpg --delete-key key-id
gpg --delete-keys username

# revoking YOUR OWN public key from your local store:
gpg --import [revocation-certificate-file]


gpg --list-keys "user@gmail.com" | grep pub -A 1 | grep -v pub
gpg --list-secret-keys
gpg --list-keys --keyid-format LONG --fingerprint
Anti tampering by using checksums and signing
shasum -a 256 myfile.txt | awk '{print $1}' >myfile.txt.sha256sum
gpg --output myfile.txt.sha256sum.sig --sign myfile.txt.sha256sum
gpg --verify myfile.txt.sha256sum.sig
gpg --output myfile.txt.sha256sum  --decrypt myfile.txt.sha256sum.sig
gpg --verify document.txt.gpg

# How to generate random bytes for gpg2 on remote ubuntu systems
aptitude install haveged

# How to create gpg keys for automations (no psw)
gpg --batch --generate-key <<EOF
%no-protection
Key-Type: default
Subkey-Type: default
Name-Real: MyApp Config 1
Name-Email: myapp-config-1@mydomain.local
Expire-Date: 0
EOF
