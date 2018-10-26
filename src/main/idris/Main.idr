module Main

import Language.JSON.Data
import IdrisJvm.IO
import IdrisJvm.System
import Java.Lang
import Java.Util
import Data.Vect
import Mmhelloworld.IdrisSpringBoot.Boot
import Mmhelloworld.IdrisSpringBoot.Web.Bind.Annotation
import Mmhelloworld.IdrisSpringBoot.Context.Annotation
import Mmhelloworld.IdrisSpringBoot.Boot.Autoconfigure
import Mmhelloworld.IdrisSpringBoot.Http.Converter.Json
import Mmhelloworld.IdrisSpringBoot.Context
import Mmhelloworld.IdrisSpringBootExample.Todo
import Mmhelloworld.IdrisSpringBootExample.TodoSerializer
import Mmhelloworld.IdrisJackson.Databind

TodoControllerClass : JVM_NativeTy
TodoControllerClass = Class "hello/TodoController"

TodoController : Type
TodoController = JVM_Native TodoControllerClass

objectMapperBuilder' : JVM_IO Jackson2ObjectMapperBuilder
objectMapperBuilder' = do
  mapperBuilder <- FFI.new (JVM_IO Jackson2ObjectMapperBuilder)
  todoDeserializer <- FFI.new (Maybe JClass -> JVM_IO TodoDeserializer) Nothing
  todoSerializer <- FFI.new (Maybe JClass -> JVM_IO TodoSerializer) Nothing
  invokeInstance "deserializerByType"
    (Jackson2ObjectMapperBuilder -> JClass -> JsonDeserializer -> JVM_IO Jackson2ObjectMapperBuilder)
    mapperBuilder
    (classLit "hello/MaybeTodo")
    (believe_me todoDeserializer)

  invokeInstance "serializerByType"
      (Jackson2ObjectMapperBuilder -> JClass -> JsonSerializer -> JVM_IO Jackson2ObjectMapperBuilder)
      mapperBuilder
      (classLit "hello/JTodo")
      (believe_me todoSerializer)

  invokeInstance "serializerByType"
        (Jackson2ObjectMapperBuilder -> JClass -> JsonSerializer -> JVM_IO Jackson2ObjectMapperBuilder)
        mapperBuilder
        (classLit "hello/MaybeTodo")
        (believe_me todoSerializer)
  pure mapperBuilder

objectMapperBuilder : JVM_IO Jackson2ObjectMapperBuilder
objectMapperBuilder = objectMapperBuilder'

putTodo' : TodoController -> Maybe Todo -> JVM_IO ()
putTodo' this todo = setStaticField TodoControllerClass "todo" (Maybe String -> JVM_IO ()) (toJsonStringTodo <$> todo)

putTodo : TodoController -> Maybe Todo -> JVM_IO ()
putTodo this todo = putTodo' this todo

getTodo' : JVM_IO (Maybe Todo)
getTodo' = do
  todoJson <- getStaticField TodoControllerClass "todo" (JVM_IO (Maybe String))
  pure $ todoJson >>= fromJsonStringTodo

getTodo : JVM_IO (Maybe Todo)
getTodo = getTodo'

classWith : String
classWith = ""

initialTodo : String
initialTodo = ""

springRun : JClass -> StringArray -> JVM_IO ConfigurableApplicationContext
springRun source args = do
  invokeStatic SpringApplicationClass "run" (JClass -> StringArray -> JVM_IO ConfigurableApplicationContext) source args

jmain' : StringArray -> JVM_IO ()
jmain' args = do
   springRun (classLit "hello/TodoApplication") args
   pure ()

jmain : StringArray -> JVM_IO ()
jmain args = jmain' args

main : JVM_IO ()
main = pure ()

restController : FFI_Export FFI_JVM "hello/TodoController" []
restController =
  Fun classWith (Anns [
        <@RequestMapping> [
            ("path", <@..> [ <@s> "/todo"]) ],

        <@RestController> [] ]) $
  Data Todo "hello/JTodo" $
  Data (Maybe Todo) "hello/MaybeTodo" $

  Fun initialTodo (ExportStaticField "todo") $

  Fun putTodo (ExportInstanceWithAnn "putTodo"
    [ <@RequestMapping> [ ("method", <@..> [ <@RequestMethod> "PUT" ])] ]
    [ [ <@RequestBody> [] ] ]
  ) $

  Fun getTodo (ExportInstanceWithAnn "getTodo" [<@RequestMapping> []] []) $

  End

restApplication : FFI_Export FFI_JVM "hello/TodoApplication" []
restApplication =
  Fun classWith (Anns [ <@SpringBootApplication> [] ]) $
  Fun jmain (ExportStatic "main") $
  Fun objectMapperBuilder (ExportInstanceWithAnn "objectMapperBuilder" [<@Bean> []] [])
  End
