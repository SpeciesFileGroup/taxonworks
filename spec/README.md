Directory Organization
======================

* **Controller** specs are routing tests - assumes that if you got to the controller, then you have permission to do 
something, but the action might fail for other reasons. The controller spec should test routing for both success and
failure of requested action.

* **Files** contain data files used for testing.

* **Features** specs have 2 types (Model & Functional). Feature model tests are things like if I don't have delete permission
the delete link should not appear. Functional tests are things like Session, Hub, Authentication (login & logout only), 
& dashboard.

* **Routing** specs test mapping from URL to controller

* **View** specs are HTML specific. Most of the view tests are combined into the  features test.
