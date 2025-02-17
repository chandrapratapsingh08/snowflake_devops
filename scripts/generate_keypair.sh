# Generate a private key
openssl genpkey -algorithm RSA -out snowflake_devops_rsa_key.p8 -pkeyopt rsa_keygen_bits:2048

# Extract the public key from the private key
openssl rsa -in snowflake_devops_rsa_key.p8 -pubout -out snowflake_devops_rsa_key.pub
