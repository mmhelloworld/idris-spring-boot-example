module Org.Springframework.Boot

import Org.Springframework.Context
import Java.Lang

namespace SpringApplication
    export
    %foreign "jvm:run,org/springframework/boot/SpringApplication"
    runSpringApplication : Class Object -> Array String -> PrimIO ConfigurableApplicationContext