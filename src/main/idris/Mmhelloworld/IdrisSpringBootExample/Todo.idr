module Mmhelloworld.IdrisSpringBootExample.Todo

import Language.JSON
import IdrisJvm.IO

%access public export

record Todo where
  constructor MkTodo
  id : Int
  todo : String

toJsonTodo : Todo -> JSON
toJsonTodo (MkTodo id todo) = JObject [("id", JNumber (cast id)), ("todo", JString todo)]

fromJsonTodo : JSON -> Maybe Todo
fromJsonTodo json = parse json where
  parseId : JSON -> Maybe Int
  parseId (JNumber id) = Just (cast id)
  parseId _ = Nothing

  parseTodo : JSON -> Maybe String
  parseTodo (JString todo) = Just todo
  parseTodo _ = Nothing

  parse : JSON -> Maybe Todo
  parse (JObject [("id", todoId), ("todo", todo)]) = MkTodo <$> parseId todoId <*> parseTodo todo

fromJsonStringTodo : String -> Maybe Todo
fromJsonStringTodo jsonStr = JSON.parse jsonStr >>= fromJsonTodo

toJsonStringTodo : Todo -> String
toJsonStringTodo = show . toJsonTodo

toJsonStringMaybeTodo : Maybe Todo -> Maybe String
toJsonStringMaybeTodo todo = toJsonStringTodo <$> todo

JTodo : Type
JTodo = JVM_Native (Class "hello/JTodo")

MaybeTodo : Type
MaybeTodo = JVM_Native (Class "hello/MaybeTodo")
