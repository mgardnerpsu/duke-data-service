# duke-data-service
See the `develop` branch for active commits.

This is an open source project for building a "data service" for researchers that allows them to:

1. Have a unified interface for storing and managing research data across multiple internal (enterprise data stores) and external (cloud data stores)
2. Have persistent unique resource locators for their data
3. Have Project-level access control lists (ACLs) to manage collaborators' permissions
3. Generate Provenance according to the W3C specification either programmatically or via a graphical user interface
4. Provide a RESTful API for data storage and management
5. Integrate with containerization technology for managing research computing environments
6. Manage research data workflows

## sub-repositories
* https://github.com/Duke-Translational-Bioinformatics/duke-data-service-portal
* https://github.com/Duke-Translational-Bioinformatics/duke-authentication-service
* https://github.com/Duke-Translational-Bioinformatics/duke-storage-service
* https://github.com/Duke-Translational-Bioinformatics/repository-dashboard-shiny

## api blueprint
http://docs.dukedataservice.apiary.io

### circleci development 
[![Circle CI](https://circleci.com/gh/Duke-Translational-Bioinformatics/duke-data-service/tree/develop.svg?style=svg)](https://circleci.com/gh/Duke-Translational-Bioinformatics/duke-data-service/tree/develop)

### circleci ua-test
[![Circle CI](https://circleci.com/gh/Duke-Translational-Bioinformatics/duke-data-service/tree/ua_test.svg?style=svg)](https://circleci.com/gh/Duke-Translational-Bioinformatics/duke-data-service/tree/ua_test)

### circleci production
[![Circle CI](https://circleci.com/gh/Duke-Translational-Bioinformatics/duke-data-service/tree/production.svg?style=svg)](https://circleci.com/gh/Duke-Translational-Bioinformatics/duke-data-service/tree/production)

### converse
[![Join the chat at https://gitter.im/Duke-Translational-Bioinformatics/duke-data-service](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Duke-Translational-Bioinformatics/duke-data-service?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


### contributing
The master branch of the project is considered the stable, production branch.
All commits should propogate from 'develop' to 'uatest', and then to master
only after UA Testing has approved changes to the code.
Here are steps for new developers to follow:

1. Git clone the project
1. git fetch origin develop
1. git checkout --track origin/develop
1. develop on develop.  As a precaution, you should always create
branches off of develop explicitly, e.g.:
  ```
  $ git branch -b try_foo develop
  ```
You should then merge branches back into devlop. You might consider
deleting the master branch from your local repository.
1. git push/pull (this will push to and pull from develop)
