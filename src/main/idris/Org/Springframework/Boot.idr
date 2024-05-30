module Org.Springframework.Boot

import System.FFI

import Org.Springframework.Context
import Java.Lang

namespace SpringApplication
    %foreign "jvm:run,org/springframework/boot/SpringApplication"
    jrun : Class Object -> Array String -> PrimIO ConfigurableApplicationContext

    export %inline
    run : Type -> Array String -> PrimIO ConfigurableApplicationContext
    run ty args = jrun (believe_me $ classLiteral {ty=ty}) args

namespace CommandLineRunner

    public export
    CommandLineRunner : Type
    CommandLineRunner = (Struct "org/springframework/boot/CommandLineRunner run" [], Array String -> PrimIO ())