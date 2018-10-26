module Mmhelloworld.IdrisSpringBootExample.TodoSerializer

import Mmhelloworld.IdrisSpringBootExample.Todo
import IdrisJvm.IO
import Mmhelloworld.IdrisJackson.Core
import Mmhelloworld.IdrisJackson.Databind

%access public export

TodoSerializerClass : JVM_NativeTy
TodoSerializerClass = Class "hello/JTodoSerializer"

TodoSerializer : Type
TodoSerializer = JVM_Native TodoSerializerClass

TodoDeserializerClass : JVM_NativeTy
TodoDeserializerClass = Class "hello/JTodoDeserializer"

TodoDeserializer : Type
TodoDeserializer = JVM_Native TodoDeserializerClass

todoSerializerConstructor' : TodoSerializer -> JClass -> JVM_IO ()
todoSerializerConstructor' this clazz = pure ()

todoSerializerConstructor : TodoSerializer -> JClass -> JVM_IO ()
todoSerializerConstructor = todoSerializerConstructor'

serializeJTodo' : TodoSerializer -> Object -> JsonGenerator -> SerializerProvider -> JVM_IO ()
serializeJTodo' this todoObj generator provider = do
    jsonStr <- invokeStatic TodoSerializerClass "toJsonStringMaybeTodo" (MaybeTodo -> JVM_IO (Maybe String)) (believe_me todoObj)
    maybe (pure ()) (invokeInstance "writeRaw" (JsonGenerator -> String -> JVM_IO ()) generator) jsonStr

serializeJTodo : TodoSerializer -> Object -> JsonGenerator -> SerializerProvider -> JVM_IO ()
serializeJTodo this todoObj generator provider = serializeJTodo' this todoObj generator provider

todoDeserializerConstructor' : TodoDeserializer -> JClass -> JVM_IO ()
todoDeserializerConstructor' this clazz = pure ()

todoDeserializerConstructor : TodoDeserializer -> JClass -> JVM_IO ()
todoDeserializerConstructor = todoDeserializerConstructor'

deserializeJTodo' : TodoDeserializer -> JsonParser -> DeserializationContext -> JVM_IO Object
deserializeJTodo' this parser _ = do
    node <- invokeInstance "readValueAsTree" (JsonParser -> JVM_IO TreeNode) parser
    todoString <- invokeInstance "toString" (JsonNode -> JVM_IO String) (believe_me node)
    todo <- invokeStatic TodoDeserializerClass "fromJsonStringTodo" (String -> JVM_IO MaybeTodo) todoString
    pure $ believe_me todo

deserializeJTodo : TodoDeserializer -> JsonParser -> DeserializationContext -> JVM_IO Object
deserializeJTodo serializer parser context = deserializeJTodo' serializer parser context

todoSerializerExports : FFI_Export FFI_JVM "hello/JTodoSerializer extends com/fasterxml/jackson/databind/ser/std/StdSerializer" []
todoSerializerExports =
    Data Todo "hello/JTodo" $
    Data (Maybe Todo) "hello/MaybeTodo" $
    Fun todoSerializerConstructor Constructor $
    Fun toJsonStringTodo (ExportStatic "toJsonStringTodo") $
    Fun toJsonStringMaybeTodo (ExportStatic "toJsonStringMaybeTodo") $
    Fun serializeJTodo (ExportInstance "serialize") $
    End

todoDeserializerExports : FFI_Export FFI_JVM "hello/JTodoDeserializer extends com/fasterxml/jackson/databind/deser/std/StdDeserializer" []
todoDeserializerExports =
    Data Todo "hello/JTodo" $
    Data (Maybe Todo) "hello/MaybeTodo" $
    Fun todoDeserializerConstructor Constructor $
    Fun fromJsonStringTodo (ExportStatic "fromJsonStringTodo") $
    Fun deserializeJTodo (ExportInstance "deserialize") $
    End