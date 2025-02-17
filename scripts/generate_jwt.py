import os
from datetime import timedelta, timezone, datetime
import jwt
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat
from cryptography.hazmat.backends import default_backend
import base64
import hashlib

# Load the private key from the file
with open('rsa_key.p8', 'rb') as pem_in:
    pemlines = pem_in.read()
    try:
        # Try to access the private key without a passphrase
        private_key = load_pem_private_key(pemlines, None, default_backend())
    except TypeError:
        # If the key is encrypted, provide the passphrase
        private_key = load_pem_private_key(
            pemlines,
            password=os.environ['SNOWFLAKE_PRIVATE_KEY_PASSWORD'].encode(),  # Passphrase for the private key
            backend=default_backend()
        )

# Generate the public key fingerprint
public_key_raw = private_key.public_key().public_bytes(Encoding.DER, PublicFormat.SubjectPublicKeyInfo)
sha256hash = hashlib.sha256()
sha256hash.update(public_key_raw)
public_key_fp = 'SHA256:' + base64.b64encode(sha256hash.digest()).decode('utf-8')

# Print the public key fingerprint for debugging
print('Public Key Fingerprint:', public_key_fp)

# Save the fingerprint to an environment variable for use in the next step
with open(os.environ['GITHUB_ENV'], 'a') as env_file:
    env_file.write(f'PUBLIC_KEY_FP={public_key_fp}\n')

# Construct the fully qualified name of the user in uppercase
account = os.environ['SNOWFLAKE_ACCOUNT']
if not '.global' in account:
    idx = account.find('.')
    if idx > 0:
        account = account[0:idx]
    else:
        idx = account.find('-')
        if idx > 0:
            account = account[0:idx]

account = account.upper()
user = os.environ['SNOWFLAKE_DEVOPS_USER'].upper()
qualified_username = account + '.' + user

# Get the current time and set the JWT expiration time
now = datetime.now(timezone.utc)
lifetime = timedelta(minutes=59)

# Create the payload for the token
payload = {
    'iss': qualified_username + '.' + public_key_fp,
    'sub': qualified_username,
    'iat': now,
    'exp': now + lifetime
}

# Generate the JWT
encoding_algorithm = 'RS256'
token = jwt.encode(payload, key=private_key, algorithm=encoding_algorithm)

# If the token is a byte string, convert it to a string
if isinstance(token, bytes):
    token = token.decode('utf-8')

# Print the generated JWT
print('Generated JWT:', token)

# Save the JWT to an environment variable for use in the next steps
with open(os.environ['GITHUB_ENV'], 'a') as env_file:
    env_file.write(f'JWT={token}\n')