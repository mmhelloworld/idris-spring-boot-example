module Mmhelloworld.IdrisSpringBootExample.Main

import Java.Lang
import Java.Util
import Org.Springframework.Context
import Org.Springframework.Boot
import System.FFI
import System
import Control.App

import Mmhelloworld.IdrisSpringBootExample.PayrollStore
import Mmhelloworld.IdrisSpringBootExample.PayrollApp

%export
    """
    jvm:import
    org/springframework/web/bind/annotation/GetMapping Get
    org/springframework/web/bind/annotation/PostMapping Post
    io/github/mmhelloworld/helloworld/Employee
    io/github/mmhelloworld/helloworld/EmployeeController
    io/github/mmhelloworld/helloworld/EmployeeRepository
    io/github/mmhelloworld/helloworld/PayrollConfiguration
    io/github/mmhelloworld/helloworld/PayrollApplication
    org/springframework/context/annotation/Configuration
    org/springframework/web/bind/annotation/RestController
    org/springframework/web/bind/annotation/RequestBody
    org/springframework/boot/CommandLineRunner
    org/springframework/boot/SpringApplication
    org/springframework/boot/autoconfigure/SpringBootApplication
    org/springframework/context/annotation/Bean
    org/springframework/stereotype/Component
    java/util/List
    """
jvmImports : List String
jvmImports = []

-- Spring boot controller that defines REST endpoints
namespace EmployeeController

    %export """
            jvm:public EmployeeController
            {
                "annotations": [
                    {"NoArgsConstructor": {}},
                    {"RestController": {}}
                ]
            }
            """
    public export
    EmployeeController : Type
    EmployeeController = Struct "io/github/mmhelloworld/helloworld/EmployeeController" []

    -- GET endpoint to retrieve all the employees
    %export """
         jvm:public getEmployees
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
    employees _ = toPrim $ run getEmployees

    -- POST endpoint to save an employee given a JSON payload
    %export """
         jvm:public saveEmployee
         {
             "annotations": [
                 {"Post": ["/employee"]}
             ],
             "enclosingType": "EmployeeController",
             "arguments": [
                 {
                     "type": "EmployeeController"
                 },
                 {
                     "type": "Employee",
                     "annotations": [
                        {"RequestBody": {}}
                     ]
                 }
             ],
             "returnType": "Employee"
         }
     """
    saveEmployee : EmployeeController -> Employee -> PrimIO Employee
    saveEmployee _ employee = toPrim $ run (PayrollApp.saveEmployee employee)

-- Spring Boot configuration class
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

    initCommandLineRunner : Array String -> PrimIO ()
    initCommandLineRunner args = toPrim $ run initDatabase

    %export """
         jvm:public initDatabase
         {
             "annotations": [
                 {"Bean": {}}
             ],
             "enclosingType": "PayrollConfiguration",
             "arguments": [
                 { "type": "PayrollConfiguration" }
             ],
             "returnType": "CommandLineRunner"
         }
     """
    initDatabaseBean : PayrollConfiguration -> CommandLineRunner
    initDatabaseBean this = jlambda initCommandLineRunner

-- Spring boot main class
namespace PayrollApplication
    %export """
            jvm:public PayrollApplication
            {
                "annotations": [
                    {"NoArgsConstructor": {}},
                    {
                        "SpringBootApplication": {
                            "scanBasePackages": [
                                "io.github.mmhelloworld.idrisspringboot",
                                "io.github.mmhelloworld.helloworld"
                            ]
                        }
                    }
                ]
            }
            """
    public export
    PayrollApplication : Type
    PayrollApplication = Struct "io/github/mmhelloworld/helloworld/PayrollApplication" []

main : IO ()
main = do
    args <- Arrays.fromList String !getArgs
    ignore $ fromPrim $ run PayrollApplication args