
import IdrisJvm.IO
import IdrisJvm.System
import IdrisJvm.JvmImport
import Java.Lang
import Java.Util
import Java.Util.Function
import Data.Vect
import Mmhelloworld.IdrisSpringBoot.Boot
import Mmhelloworld.IdrisSpringBoot.Web.Bind.Annotation
import Mmhelloworld.IdrisSpringBoot.Context.Annotation
import Mmhelloworld.IdrisSpringBoot.Boot.Autoconfigure
import Mmhelloworld.IdrisSpringBoot.Context

%access public export

namespace BeanDefinitionCustomizer
    BeanDefinitionCustomizer : Type
    BeanDefinitionCustomizer = javaInterface "org/springframework/beans/factory/config/BeanDefinitionCustomizer"

namespace GenericApplicationContext
  GenericApplicationContext : Type
  GenericApplicationContext = javaClass "org/springframework/context/support/GenericApplicationContext"

  registerBean : GenericApplicationContext -> JClass -> Supplier -> JVM_Array BeanDefinitionCustomizer -> JVM_IO ()
  registerBean = invokeInstance "registerBean" (GenericApplicationContext -> JClass -> Supplier -> JVM_Array BeanDefinitionCustomizer -> JVM_IO ())

Inherits ConfigurableApplicationContext GenericApplicationContext where {}

namespace ApplicationContextInitializer
  ApplicationContextInitializer : Type
  ApplicationContextInitializer = javaInterface "org/springframework/context/ApplicationContextInitializer"

  %inline
  jlambda : (ConfigurableApplicationContext -> JVM_IO ()) -> ApplicationContextInitializer
  jlambda f = javalambda "initialize" (ConfigurableApplicationContext -> JVM_IO ()) g
    where
      g : ConfigurableApplicationContext -> ()
      g context = believe_me $ unsafePerformIO (f context)

namespace ApplicationArguments
    ApplicationArguments : Type
    ApplicationArguments = javaInterface "org/springframework/boot/ApplicationArguments"

namespace SpringApplicationBuilder
  SpringApplicationBuilder : Type
  SpringApplicationBuilder = javaClass "org/springframework/boot/builder/SpringApplicationBuilder"

  new : JVM_Array JClass -> JVM_IO SpringApplicationBuilder
  new = FFI.new (JVM_Array JClass -> JVM_IO SpringApplicationBuilder)

  initializers : SpringApplicationBuilder -> JVM_Array ApplicationContextInitializer -> JVM_IO SpringApplicationBuilder
  initializers = invokeInstance "initializers" (SpringApplicationBuilder -> JVM_Array ApplicationContextInitializer -> JVM_IO SpringApplicationBuilder)

  run : SpringApplicationBuilder -> StringArray -> JVM_IO ConfigurableApplicationContext
  run = invokeInstance "run" (SpringApplicationBuilder -> StringArray -> JVM_IO ConfigurableApplicationContext)

namespace ApplicationRunner
  ApplicationRunner : Type
  ApplicationRunner = javaInterface "org/springframework/boot/ApplicationRunner"

  clazz : JClass
  clazz = classLit "org/springframework/boot/ApplicationRunner"

  %inline
  jlambda : (ApplicationArguments -> JVM_IO ()) -> ApplicationRunner
  jlambda f = javalambda "run" (ApplicationArguments -> JVM_IO ()) g
    where
      g : ApplicationArguments -> ()
      g args = believe_me $ unsafePerformIO (f args)

namespace Publisher
    PublisherClass : JVM_NativeTy
    PublisherClass = Interface "org/reactivestreams/Publisher"

    Publisher : Type
    Publisher = javaInterface "org/reactivestreams/Publisher"

namespace Mono
    MonoClass : JVM_NativeTy
    MonoClass = Class "reactor/core/publisher/Mono"

    Mono : Type
    Mono = javaClass "reactor/core/publisher/Mono"

    just : a -> JVM_IO Mono
    just d = invokeStatic MonoClass "just" (Object -> JVM_IO Mono) $ believe_me d

MonoClass inherits PublisherClass

namespace ServerRequest
    ServerRequest : Type
    ServerRequest = javaInterface "org/springframework/web/reactive/function/server/ServerRequest"

namespace HandlerFunction
    HandlerFunction : Type
    HandlerFunction = javaInterface "org/springframework/web/reactive/function/server/HandlerFunction"

    %inline
    jlambda : (ServerRequest -> JVM_IO Mono) -> HandlerFunction
    jlambda f = javalambda "handle" (ServerRequest -> JVM_IO Mono) g
       where
         g : ServerRequest -> Mono
         g request = unsafePerformIO (f request)

namespace RequestPredicate
    RequestPredicate : Type
    RequestPredicate = javaInterface "org/springframework/web/reactive/function/server/RequestPredicate"

namespace RequestPredicates
    RequestPredicatesClass : JVM_NativeTy
    RequestPredicatesClass = Class "org/springframework/web/reactive/function/server/RequestPredicates"

    get : String -> JVM_IO RequestPredicate
    get = invokeStatic RequestPredicatesClass "GET" (String -> JVM_IO RequestPredicate)

namespace RouterFunction
    RouterFunctionClass : JVM_NativeTy
    RouterFunctionClass = Class "org/springframework/web/reactive/function/server/RouterFunction"

    RouterFunction : Type
    RouterFunction = javaInterface "org/springframework/web/reactive/function/server/RouterFunction"

    clazz : JClass
    clazz = classLit "org/springframework/web/reactive/function/server/RouterFunction"

namespace RouterFunctions
    RouterFunctionsClass : JVM_NativeTy
    RouterFunctionsClass = Class "org/springframework/web/reactive/function/server/RouterFunctions"

    route : RequestPredicate -> HandlerFunction -> JVM_IO RouterFunction
    route = invokeStatic RouterFunctionsClass "route" (RequestPredicate -> HandlerFunction -> JVM_IO RouterFunction)

namespace ServerResponse
    namespace BodyBuilder
        BodyBuilderClass : JVM_NativeTy
        BodyBuilderClass = Class "org/springframework/web/reactive/function/server/ServerResponse$BodyBuilder"

        BodyBuilder : Type
        BodyBuilder = javaInterface "org/springframework/web/reactive/function/server/ServerResponse$BodyBuilder"

        body : BodyBuilder -> Publisher -> JClass -> JVM_IO Mono
        body = invokeInstance "body" (BodyBuilder -> Publisher -> JClass -> JVM_IO Mono)

    ServerResponseClass : JVM_NativeTy
    ServerResponseClass = Interface "org/springframework/web/reactive/function/server/ServerResponse"

    ok : JVM_IO BodyBuilder
    ok = invokeStatic ServerResponseClass "ok" (JVM_IO BodyBuilder)

classWith : String
classWith = ""

ok : String -> JVM_IO Mono
ok str = body !ServerResponse.ok !(just str) (classLit "java/lang/String")

Bean : Type
Bean = ConfigurableApplicationContext -> JVM_IO ()

runner : (ApplicationArguments -> JVM_IO ()) -> Bean
runner f context = do
  let genericContext = the GenericApplicationContext (believe_me context)
  let beanSupplier = Supplier.jlambda $ pure (ApplicationRunner.jlambda f)
  noCustomizers <- newArray BeanDefinitionCustomizer 0
  registerBean genericContext ApplicationRunner.clazz beanSupplier noCustomizers

route : RequestPredicate -> (ServerRequest -> JVM_IO Mono) -> Bean
route requestPredicate f context = do
  let genericContext = the GenericApplicationContext (believe_me context)
  let beanSupplier = Supplier.jlambda $ RouterFunctions.route requestPredicate $ HandlerFunction.jlambda f
  noCustomizers <- newArray BeanDefinitionCustomizer 0
  registerBean genericContext RouterFunction.clazz beanSupplier noCustomizers

get : String -> (ServerRequest -> JVM_IO Mono) -> Bean
get pattern f context = do
  requestPredicate <- RequestPredicates.get pattern
  route requestPredicate f context

registerBeans : List Bean -> ConfigurableApplicationContext -> JVM_IO ()
registerBeans [] context = pure ()
registerBeans (bean :: beans) context = do
  bean context
  registerBeans beans context

runSpring : JClass -> List Bean -> StringArray -> JVM_IO ()
runSpring clazz beans args = do
  sources <- listToArray [clazz]
  appBuilder <- SpringApplicationBuilder.new sources
  let initializer = ApplicationContextInitializer.jlambda (registerBeans beans)
  _ <- initializers appBuilder !(listToArray [initializer])
  SpringApplicationBuilder.run appBuilder args
  pure ()
