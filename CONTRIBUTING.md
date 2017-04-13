Contributing
============

###  How do I report a bug?

First [read this][14].

Use the [issue tracker][13]. You can use [waffle.io](https://waffle.io/SpeciesFileGroup/taxonworks) to do this as well. 

Some other conventions:

* Categorize your issue using a label.
* Use the prefix "task -" in the name to indicate the request for a new or improved task.
* Use the prefix of your project name if reporting errors with a specific project.

###  How do I set up my development environment?

See the [tw_provision repo][5].

###  How do I submit changes to the code base? 

To get started, first [fork][1] this project on GitHub and follow the Installation steps listed above. Then make a new branch off of "development" and name it in the format of "feature-name" and start programming. The workflow for this project is that subsequent pulls from the "development" branch should be rebased into the new feature branch so that the latest commits on the feature branch are related to the feature that is being implemented, a more indepth explanation of this practice can be found [here][2]. Once the feature has been completed and tested thoroughly, submit a pull request to this repo and wait for it to be looked at and hopefully approved.

###  Where can I ask for help? 

[![Gitter][4]][3].

###  Documentation

TaxonWorks code [documentation][10] is done inline with [Yard tags][12]. 

### Is there a database schema I can see? ####

See [db/schema.rb](db/schema.rb), or, better, checkout out the model [documentation][10].  You can also use a rake task to generate the current SQL structure, or Rails schema.rb.

[1]: https://help.github.com/articles/fork-a-repo/
[2]: https://www.atlassian.com/git/tutorials/merging-vs-rebasing
[3]: https://gitter.im/SpeciesFileGroup/taxonworks?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge
[4]: https://badges.gitter.im/SpeciesFileGroup/taxonworks.svg
[5]: https://github.com/SpeciesFileGroup/tw_provision
[10]: http://rdoc.taxonworks.org/frames
[12]: http://rdoc.info/gems/yard/file/docs/Tags.md
[13]: https://github.com/SpeciesFileGroup/taxonworks/issues
[14]: http://wiki.taxonworks.org/index.php/Feedback 
