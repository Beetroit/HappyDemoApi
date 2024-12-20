import jwt, times, json, tables, options
proc dumpToken*(
    userId: string, data: Option[JsonNode], expires = (getTime() + 4.hours).toUnix(), secret: string = ""
): string =
  var token_dict =
    %*{
      "header": {"alg": "HS256", "typ": "JWT"},
      "claims": {"userId": userId, "exp": expires},
    }
  if data.isSome():
    for k, v in data.get():
      token_dict["claims"][k] = v
  
  var token = toJWT(token_dict)

  token.sign(secret)

  result = $token

proc verifyToken*(token: string, secret: string = ""): bool =
  try:
    let jwtToken = token.toJWT()
    result = jwtToken.verify(secret, HS256)
  except InvalidToken:
    result = false

proc decodeJwt*(token: string): string =
  let jwt = token.toJWT()
  result = $jwt.claims["userId"].node.str
