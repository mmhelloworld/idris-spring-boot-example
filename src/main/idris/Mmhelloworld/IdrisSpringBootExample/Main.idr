module Mmhelloworld.IdrisSpringBootExample.Main

import Java.Lang
import Java.Util
import Org.Springframework.Context
import Org.Springframework.Boot
import Org.Springframework.Data.Jpa.Repository
import System.FFI
import System

%export
    """
    jvm:import
    org/springframework/web/bind/annotation/GetMapping Get
    io/github/mmhelloworld/helloworld/Employee
    io/github/mmhelloworld/helloworld/EmployeeController
    io/github/mmhelloworld/helloworld/EmployeeRepository
    io/github/mmhelloworld/helloworld/PayrollConfiguration
    io/github/mmhelloworld/helloworld/PayrollApplication
    org/springframework/context/annotation/Configuration
    org/springframework/web/bind/annotation/RestController
    org/springframework/data/jpa/repository/JpaRepository
    org/springframework/boot/CommandLineRunner
    org/springframework/boot/SpringApplication
    org/springframework/boot/autoconfigure/SpringBootApplication
    org/springframework/context/annotation/Bean
    java/util/List
    java/lang/Long
    java/lang/Thread
    jakarta/persistence/Entity
    jakarta/persistence/Id
    jakarta/persistence/GeneratedValue
    """
jvmImports : List String
jvmImports = []

namespace Employee
    %export """
            jvm:public Employee
            {
                "annotations": [
                    {"Data": {}},
                    {"AllArgsConstructor": {
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
                    "name": "String",
                    "role": "String"
                }
            }
            """
    public export
    Employee : Type
    Employee = Struct "io/github/mmhelloworld/helloworld/Employee" []

    %foreign "jvm:<init>"
    prim_new : String -> String -> PrimIO Employee

    export %inline
    new : HasIO io => String -> String -> io Employee
    new name role = primIO $ prim_new name role

namespace EmployeeRepository

    %export """
        jvm:public abstract interface EmployeeRepository
        {
            "extends": ["JpaRepository<Employee, Long>"]
        }
        """
    public export
    EmployeeRepository : Type
    EmployeeRepository = Struct "io/github/mmhelloworld/helloworld/EmployeeRepository" []

Inherits EmployeeRepository (CrudRepository Employee Int64) where
Inherits EmployeeRepository (JpaRepository Employee Int64) where

namespace EmployeeController

    %export """
            jvm:public EmployeeController
            {
                "fields": {
                    "employeeRepository": {
                        "modifiers": ["private", "final"],
                        "type": "EmployeeRepository"
                    }
                },
                "annotations": [
                    {"AllArgsConstructor": {}},
                    {"Getter": {}},
                    {"RestController": {}}
                ]
            }
            """
    public export
    EmployeeController : Type
    EmployeeController = Struct "io/github/mmhelloworld/helloworld/EmployeeController" []

    %foreign "jvm:.getEmployeeRepository"
    repository : EmployeeController -> PrimIO EmployeeRepository

    %export """
         jvm:public getEmployees!
         {
             "annotations": [
                 {"Get": ["/employees"]}
             ],
             "enclosingType": "EmployeeController",
              "arguments": [
                  {
                      "type": "EmployeeController"
                  }
              ],
              "returnType": "List<Employee>"
         }
     """
    employees : EmployeeController -> PrimIO (JList Employee)
    employees this = toPrim $ do
        employeeRepository <- fromPrim $ repository this
        findAll {id=Int64} (subtyping employeeRepository)

namespace CommandLineRunner

    public export
    CommandLineRunner : Type
    CommandLineRunner = (Struct "org/springframework/boot/CommandLineRunner run" [], Array String -> PrimIO ())

namespace PayrollConfiguration
    %export """
            jvm:public PayrollConfiguration
            {
                "annotations": [
                    {"NoArgsConstructor": {}},
                    {"Configuration": {}}
                ]
            }
            """
    public export
    PayrollConfiguration : Type
    PayrollConfiguration = Struct "io/github/mmhelloworld/helloworld/PayrollConfiguration" []

    initCommandLineRunner : EmployeeRepository -> Array String -> PrimIO ()
    initCommandLineRunner repository args = toPrim $ do
        printLn $ "Loading database..."
        ignore $ save {entity=Employee} {id=Int64} (subtyping repository) !(Employee.new "Bilbo Baggins" "burglar")
        ignore $ save {entity=Employee} {id=Int64} (subtyping repository) !(Employee.new "Frodo Baggins" "thief")

    %export """
         jvm:public initDatabase
         {
             "annotations": [
                 {"Bean": {}}
             ],
             "enclosingType": "PayrollConfiguration",
             "arguments": [
                 { "type": "PayrollConfiguration" },
                 { "type": "EmployeeRepository" }
             ],
             "returnType": "CommandLineRunner"
         }
     """
    initDatabase : PayrollConfiguration -> EmployeeRepository -> CommandLineRunner
    initDatabase this repository = jlambda (initCommandLineRunner repository)

namespace PayrollApplication
    %export """
            jvm:public PayrollApplication
            {
                "annotations": [
                    {"NoArgsConstructor": {}},
                    {"SpringBootApplication": {}}
                ]
            }
            """
    public export
    PayrollApplication : Type
    PayrollApplication = Struct "io/github/mmhelloworld/helloworld/PayrollApplication" []

    %export """
            jvm:public static main!
            {
                "enclosingType": "PayrollApplication",
                "arguments": [
                    { "type": "[String" }
                ],
                "returnType": "void"
            }
            """
    export
    main : Array String -> IO ()
    main args = ignore $ fromPrim $ runSpringApplication (believe_me $ classLiteral {ty=PayrollApplication}) args

main : IO ()
main = do
    args <- Arrays.fromList String !getArgs
    PayrollApplication.main args