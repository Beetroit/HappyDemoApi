# Import HappyX
import happyx
import routes/user_routes
import models/user_models
import norm/[sqlite]
import zippy
type Operation = enum
  add
  sub
  mul
  divi

model DataModel:
  left:
    float
  op:
    Operation
  right:
    float

# Serve at http://127.0.0.1:5000
serve "127.0.0.1", 5000:
  setup:
    let dbConn = sqlite.open("test.db", "", "", "")
    addHandler newConsoleLogger(fmtStr = verboseFmtStr)

    dbConn.createTables(newUser())
  # middleware:
  #   echo "Middleware"
  #   echo headers.getOrDefault("accept-encoding")
  notFound:
    return {"response": "Not found"}

  get "/":
    "Hello, World!"

  post "/calc[data:DataModel:json]":
    let left = data.left
    let right = data.right
    let op = data.op
    case op
    of add:
      fmt"{left + right}"
    of sub:
      fmt"{left - right}"
    of divi:
      fmt"{left / right}"
    of mul:
      fmt"{left * right}"
  mount "/users" -> User
  finalize:
    echo "Byeeee"
