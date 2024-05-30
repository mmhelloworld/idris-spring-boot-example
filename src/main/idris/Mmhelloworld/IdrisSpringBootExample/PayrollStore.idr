module Mmhelloworld.IdrisSpringBootExample.PayrollStore

import Org.Springframework.Data.Jpa.Repository
import System.FFI
import Java.Lang

%export
    """
    jvm:import
    org/springframework/web/bind/annotation/GetMapping Get
    io/github/mmhelloworld/helloworld/Employee
    io/github/mmhelloworld/helloworld/EmployeeRepository
    org/springframework/data/jpa/repository/JpaRepository
    com/fasterxml/jackson/annotation/JsonProperty
    com/fasterxml/jackson/annotation/JsonCreator
    java/util/List
    java/lang/Long
    jakarta/persistence/Entity
    jakarta/persistence/Id
    jakarta/persistence/GeneratedValue
    """
jvmImports : List String
jvmImports = []

namespace Employee

    {-
     - Employee database entity with primary key "id" and fields name and role
     -}
    %export """
            jvm:public Employee
            {
                "annotations": [
                    {"Data": {}},
                    {"AllArgsConstructor": {
                        "annotations": [
                            {"JsonCreator": {}}
                        ],
                        "parameterAnnotations": [
                            [{"JsonProperty": "name"}],
                            [{"JsonProperty": "role"}]
                        ],
                        "exclude": ["id"]}},
                    {"NoArgsConstructor": {}},
                    {"Entity": {}}
                ],
                "fields": {
                    "id": {
                        "type": "java/lang/Long",
                        "annotations": [
                            {"Id": {}},
                            {"GeneratedValue": {}}
                        ]
                    },
                    "name": {
                        "type": "String"
                    },
                    "role": {
                        "type": "String"
                    }
                }
            }
            """
    public export
    Employee : Type
    Employee = Struct "io/github/mmhelloworld/helloworld/Employee" []

    export
    %foreign "jvm:<init>"
    new : String -> String -> Employee

namespace EmployeeRepository

    {-
     - Repository to manage employees in database
     -}
    %export """
        jvm:public abstract interface EmployeeRepository
        {
            "extends": ["JpaRepository<Employee, Long>"]
        }
        """
    public export
    EmployeeRepository : Type
    EmployeeRepository = Struct "io/github/mmhelloworld/helloworld/EmployeeRepository" []

export
Inherits EmployeeRepository (CrudRepository Employee Int64) where

export
Inherits EmployeeRepository (JpaRepository Employee Int64) where