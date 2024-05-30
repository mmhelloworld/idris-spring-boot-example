module Org.Springframework.Data.Jpa.Repository

import Java.Lang
import Java.Util
import System.FFI

%hide Prelude.Basics.id

%export
    """
    jvm:import
    org/springframework/data/repository/CrudRepository
    """
jvmImports : List String
jvmImports = []

namespace CrudRepository
    public export
    CrudRepository : (entity: Type) -> (id: Type) -> Type
    CrudRepository entity id = Struct "i:org/springframework/data/repository/CrudRepository" [("<>", entity), ("<>", id)]

    %foreign "jvm:.save"
    prim_save : CrudRepository entity id -> entity -> PrimIO entity

    export %inline
    save : HasIO io => CrudRepository entity id -> entity -> io entity
    save repository entity = primIO $ prim_save repository entity

namespace JpaRepository
    public export
    JpaRepository : (entity: Type) -> (id: Type) -> Type
    JpaRepository entity id = Struct "i:org/springframework/data/jpa/repository/JpaRepository" [("<>", entity), ("<>", id)]

    %foreign "jvm:.findAll"
    prim_findAll : JpaRepository entity id -> PrimIO (JList entity)

    export %inline
    findAll : HasIO io => JpaRepository entity id -> io (JList entity)
    findAll repository = primIO $ prim_findAll repository

public export
Inherits (JpaRepository entity id) (CrudRepository entity id) where