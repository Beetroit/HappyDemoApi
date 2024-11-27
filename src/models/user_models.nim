import std/[strformat, logging]
import norm/[model]

addHandler newConsoleLogger(fmtStr = "")

type User* = ref object of Model
  name*: string
  age*: int

func newUser*(name = "", age = 0): User =
  User(name: name, age: age)

func `$`*(self: User): string =
  result = fmt"User(id={self.id}, name={self.name}, age={self.age})"
