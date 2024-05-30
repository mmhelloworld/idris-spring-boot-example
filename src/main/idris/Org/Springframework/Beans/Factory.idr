module Org.Springframework.Beans.Factory

import Java.Lang
import System.FFI

namespace BeanFactory
    public export
    BeanFactory : Type
    BeanFactory = Struct "i:org/springframework/beans/factory/BeanFactory" []

    %foreign "jvm:.getBean"
    prim_getBean : BeanFactory -> Class ty -> PrimIO (ty)

    public export
    getBean : (Inherits beanFactory BeanFactory, HasIO io) => beanFactory -> Class ty -> io ty
    getBean beanFactory clazz = primIO $ prim_getBean (subtyping beanFactory) clazz
