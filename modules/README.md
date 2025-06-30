# MODULES

Root/Deployment Module (examples/hello-world-deployment)
    ↓
Composition Module (modules/services/hello-world-app)  ← Your module
    ↓
Base Modules (modules/cluster/asg, modules/networking/alb)
    ↓
Resource Modules (individual AWS resources)

# COMPOSITION MODULE
"Composition Module" is the most widely accepted term in the Terraform community for modules that orchestrate other modules to create a complete solution.
# Other Terms that refers to COMPOSITION MODULE:
Composite Module - Same as composition module

Wrapper Module - When it primarily wraps other modules with minimal logic

Service Module - When it represents a complete service/application

Higher-level Module - Indicates it's at a higher abstraction level
We will refactor the webserver_cluster module in chapter 5 into three smaller modules.


## SELF VALIDATING MODULES

# Validations Blocks:
- Used to perform checks on input variables

# Precondition Blocks:
- Used on resource, data sources, and output variables to perform more dynamic checks.
- This is for catching errors before you run "terraform apply"

# Postcondition Blocks:
- Used for catching errors after you run apply.
Example use case:
- To Check that ASG was deployed in more than one AZ

