#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

# Generate a random value for the password.
password=$(openssl rand -base64 32)

# Convert the full chain and private key PEMs into a single P12 file.
#
# This is a Terraform template file, and the domain, full_chain_pem,
# and priv_key_pem variables are passed in via templatefile().
#
# shellcheck disable=SC2154
openssl pkcs12 -export -in "${full_chain_pem}" -inkey "${priv_key_pem}" \
  -out "/tmp/${domain}.p12" -name "${domain}" -passout pass:"$password"

# Create the Java keystore from the P12 file.
#
# TODO: issue cisagov/cool-assessment-terraform#121 suggests improving
# this code by allowing the user to specify the location of the Java
# keystore.
#
# This is a Terraform template file, and the c2_profile_location and
# domain variables are passed in via templatefile().
#
# shellcheck disable=SC2154
keytool -importkeystore \
  -deststorepass "$password" -destkeypass "$password" \
  -destkeystore "${c2_profile_location}/${domain}.store" \
  -srckeystore "/tmp/${domain}.p12" -srcstoretype PKCS12 \
  -srcstorepass "$password" -alias "${domain}"

# Append the https-certificate block to the Amazon and OCSP C2
# profiles.
cat > /tmp/cert-block.txt << CERT_BLOCK

https-certificate {
  set keystore "${domain}.store";
  set password "$password";
}
CERT_BLOCK

# Append the https-certificate blocks to the Cobalt Strike C2
# profiles.
#
# TODO: issue cisagov/cool-assessment-terraform#121 suggests improving
# this code by allowing the user to specify the Cobalt Strike C2 profiles
# to which an https-certificate block should be added.
#
# This is a Terraform template file, and the c2_profile_location
# variable is passed in via the templatefile().
#
# shellcheck disable=SC2154
cat /tmp/cert-block.txt >> "${c2_profile_location}/amazon.profile"
cat /tmp/cert-block.txt >> "${c2_profile_location}/ocsp.profile"

# Clean up
rm /tmp/cert-block.txt
