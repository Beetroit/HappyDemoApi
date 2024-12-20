import happyx
import ../models/user_models
import norm/sqlite
import json
from zippy import compress

model ProfileModel:
    age:
        int
    name:
        string

model GetUser:
    id:
        int

mount User:
    
    post "/new[data:ProfileModel:json]":
        var user = newUser(data.name, data.age)

        try:
            dbConn.insert(user)
            return {"response": "success"}
        except DbError:
            return {"response": "failure"}

    @AuthBearerJWT(token)
    get "/get":
        for k, v in token.pairs():
            echo k, %v
        let id = query ? id
        var user: User = newUser()
        try:
            dbConn.select(user, "id = ?", id)
            statusCode = 200
            var resp_data: JsonNode = %*{"id": user.id, "name": $user.name, "age": user.age}
            var zipped_data = compress($resp_data, BestSpeed, dfGzip)
            outHeaders["Content-Encoding"] = "gzip"
            outHeaders["Content-Type"] = "application/json"
            return zipped_data
        except DbError, NotFoundError:
            statusCode = 404
            return {"response": getCurrentExceptionMsg()}

    @Cached(20)
    get "/all":
        # TODO: add cache layer
        var users = @[newUser()]
        dbConn.selectAll(users)
        var response = %*[]
        if len(users) == 0:
            statusCode = 404
            return {"response": "No users found"}
        for i in users:
            response.add %*{"name": $i.name, "age": i.age, "id": i.id}
        outHeaders["Content-Type"] = "application/json"
        outHeaders["Content-Encoding"] = "gzip"
        var zipped_data = compress($response, BestSpeed, dfGzip)
        return zipped_data

    post "/delete[data:GetUser:json]":
        var user = newUser()
        try:
            dbConn.select(user, "id = ?", data.id.int64)
            dbConn.delete(user)
            statusCode = 204
            return {"response": "success"}
        except DbError, NotFoundError:
            statusCode = 400
            return {"response": getCurrentExceptionMsg()}
    
