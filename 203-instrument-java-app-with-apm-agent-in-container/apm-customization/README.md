# APM customization

This folder contains the customization files that will be copied into the container image

- config/*.json: custom configuration files exported from the webconsole (CONFIGURE > AGENTS > Configurations)

- config/initial-mapping: startup instrumentation definition, mapping processes to configuration files 

- config/tags.yaml: list of tags, decorating the agent 

- install.properties: installer properties