# Import HappyX
import happyx
import routes/user_routes
import models/user_models
from services/auth_service import dumpToken
import norm/[sqlite]
import zippy
import jwt
import tables, options

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
    onException:
        echo e.msg
        echo e.name
        return {"error": getCurrentExceptionMsg()}

    setup:
        let dbConn = sqlite.open("test.db", "", "", "")
        addHandler newConsoleLogger(fmtStr = verboseFmtStr)

        dbConn.createTables(newUser())

    notFound:
        return {"response": "Not found"}

    get "/":
        "Hello, World!"

    mount "/users" -> User

    @AuthBearerJWT(token)
    post "/calc[data:DataModel:json]":
        echo  token["userId"].node
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
    
    post "/login[data:GetUser:json]":
        echo data
        var user = newUser()
        try:
            dbConn.select(user, "id = ?", data.id.int64)
            var data = %*{"name": user.name, "age": user.age}
            var secret = "secret"
            
            try:
                echo secret
            except Exception as e:
                echo getCurrentExceptionMsg()
            var auth_token= dumpToken($user.id, data=some(data), secret=secret)
            return {"token": auth_token}
        except:
            return {"error": "Invalid credentials"}
    
    get "/test":
        "Success"

    @Cached(10)
    get "/test_json":
        return "response"

    finalize:
        echo "Byeeee"
