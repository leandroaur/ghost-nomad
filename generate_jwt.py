import jwt
import time
import sys

# Verifica se a chave foi passada como argumento
if len(sys.argv) != 2:
    print("Uso: python3.8 generate_jwt.py <API_ADMIN_KEY_SECRET>")
    sys.exit(1)

# Pega a chave do argumento passado
key = sys.argv[1]

# Divide a chave em ID e segredo
key_id, secret = key.split(":")

# Cria o payload
iat = int(time.time())  # Tempo de emissão
exp = iat + 300         # Token válido por 5 minutos (300 segundos)
aud = "/admin/"         # Público para a API do Ghost Admin

payload = {
    "iat": iat,
    "exp": exp,
    "aud": aud
}

# Gera o token
token = jwt.encode(payload, bytes.fromhex(secret), algorithm="HS256", headers={"kid": key_id})

# Grava o token em uma variável (já gerado na linha acima)
jwt_token = token

# Exibe o token
print(jwt_token)
