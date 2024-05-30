module Org.Springframework.Context

import Java.Lang
import System.FFI
import Org.Springframework.Beans.Factory
import Control.App

%export
    """
    jvm:import
    io/github/mmhelloworld/idrisspringboot/SpringContext
    org/springframework/context/annotation/Configuration
    org/springframework/context/ApplicationContext
    org/springframework/context/ApplicationContextAware
    org/springframework/stereotype/Component
    """
jvmImports : List String
jvmImports = []

public export
ConfigurableApplicationContext : Type
ConfigurableApplicationContext = Struct "org/springframework/context/ConfigurableApplicationContext" []

namespace ApplicationContext
    public export
    ApplicationContext : Type
    ApplicationContext = Struct "org/springframework/context/ApplicationContext" []

public export
Inherits ApplicationContext BeanFactory where

namespace SpringContext
    %export """
            jvm:public SpringContext
            {
                "annotations": [
                    {"NoArgsConstructor": {}},
                    {"Component": {}}
                ],
                "fields": {
                    "applicationContext": {
                        "type": "ApplicationContext",
                        "modifiers": ["public", "static"]
                    }
                },
                "implements": ["ApplicationContextAware"]
            }
            """
    public export
    SpringContext : Type
    SpringContext = Struct "io/github/mmhelloworld/idrisspringboot/SpringContext" []

    %foreign "jvm:#=applicationContext(org/springframework/context/ApplicationContext void),io/github/mmhelloworld/idrisspringboot/SpringContext"
    setApplicationContext : ApplicationContext -> PrimIO ()

    %foreign "jvm:#applicationContext(org/springframework/context/ApplicationContext),io/github/mmhelloworld/idrisspringboot/SpringContext"
    prim_getApplicationContext : PrimIO ApplicationContext

    public export
    getApplicationContext : HasIO io => io ApplicationContext
    getApplicationContext = primIO prim_getApplicationContext

    %export """
            jvm:public setApplicationContext
            {
                "enclosingType": "SpringContext",
                "arguments": [
                    { "type": "SpringContext" },
                    { "type": "ApplicationContext" }
                ],
                "returnType": "void"
            }
            """
    setApplicationContextExport : SpringContext -> ApplicationContext -> PrimIO ()
    setApplicationContextExport this applicationContext = setApplicationContext applicationContext

public export
interface SpringContextAware e where
    getBean : Class ty -> App e ty

public export
Has [App.PrimIO] e => SpringContextAware e where
    getBean clazz = do
        context <- primIO getApplicationContext
        App.primIO $ BeanFactory.getBean context clazz