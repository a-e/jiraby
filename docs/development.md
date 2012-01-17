Development
===========

Testing
-------

Jiraby is tested using a locally-installed instance of Jira. For licensing and
size reasons that should be obvious, this local instance is not included in the
Jiraby codebase itself. Here are the assumptions that the Jiraby test suite
makes about your local Jira instance:

- It's running at http://localhost:8080/
- There is an administrator (in the 'jira-administrators' group):
    - Username: admin
    - Password: admin
- There is a regular user (in the 'jira-users' group):
    - Username: user
    - Password: user
- There is a project called 'TST'

