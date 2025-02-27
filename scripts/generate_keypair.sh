# Generate a private key
openssl genrsa 2048 | openssl pkcs8 -topk8 -v2 des3 -inform PEM -out rsa_key.p8

# https://govcloud.keepersecurity.us/vault/#detail/Ve0DZJJZ6t3qcTHl-M5qZg

# Generate Base64 encoded private key
base64 rsa_key.p8 > rsa_key.p8.b64

# Extract the public key from the private key
openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
