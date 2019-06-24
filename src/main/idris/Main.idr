module Main

import Language.JSON.Data
import IdrisJvm.IO
import IdrisJvm.System
import IdrisJvm.JvmImport
import Java.Lang
import Java.Util
import Java.Util.Function
import Data.Vect
import Mmhelloworld.IdrisSpringBoot.Boot.Autoconfigure
import Io.Github.Mmhelloworld.SpringBoot

%access public export
%hide Java.Util.HashMap.get

onApplicationReady : ApplicationArguments -> JVM_IO ()
onApplicationReady args = printLn "hello from Idris"

greet : ServerRequest -> JVM_IO Mono
greet request = ok "hello world"

beans : List Bean
beans = [
    runner onApplicationReady,
    get "/greet" greet
]

springMain : StringArray -> JVM_IO ()
springMain args = runSpring (classLit "main/IdrisSpringMain") beans args

main : JVM_IO ()
main = pure ()

exportSpringBootApp : FFI_Export FFI_JVM "main/IdrisSpringMain" []
exportSpringBootApp =
  Fun classWith (Anns [ <@SpringBootApplication> [] ]) $
  Fun springMain (ExportStatic "main") $
  End
