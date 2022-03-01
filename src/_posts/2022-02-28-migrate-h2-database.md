---
layout: post
title: Migrate H2 from 1.x.y to 2.x.y
date: 2022-02-28 16:00 -0800
---
If you have seen the following error:

```
[HY000][50000] General error: "The write format 1 is smaller than the supported format 2 [2.1.210/5]" [50000-210]
The write format 1 is smaller than the supported format 2 [2.1.210/5].
```

You probably upgraded your H2 dependency from 1.x.y to 2.x.y due to a suggestion from [Dependabot](https://github.com/dependabot), like this one:

![dependabot alerts]({{ site.baseurl }}/assets/2022-02-28-h2-dependabot-alerts.png)

While I'm glad these alerts exist, there's little information on how to update your existing H2 database.

## Solution

I've gone about this by doing the following steps:

* Create a backup of the v1 H2 database
* Create a new database v2 H2 database with that backup

### Download H2 Lib

The tricky part is that you must use the correct library version for this to work out, but otherwise it's a straightforward process. Let's begin by obtaining the H2 jar from Maven Central, we'll need both v1 and v2:

```sh
# Download v1
curl -Lo h2-v1.jar https://search.maven.org/remotecontent\?filepath\=com/h2database/h2/1.4.200/h2-1.4.200.jar

# Download v2
curl -Lo h2-v2.jar https://search.maven.org/remotecontent\?filepath\=com/h2database/h2/2.1.210/h2-2.1.210.jar
```

### Create Backup SQL Script 
> Please create a backup of your current H2 database at this time, it would be a shame if it got deleted.

The H2 library contains a tool called [Script](https://h2database.com/javadoc/org/h2/tools/Script.html) that we will use to generate the `backup.sql` script:

``` sh
# For a set of all possible options, run with -help
java -cp h2-v1.jar org.h2.tools.Script -url "jdbc:h2:file:path/to/database/h2.db" -script backup.sql
```

I'd take a quick peek at the `backup.sql` file just to make sure the data is there, but otherwise we're done with this step.

### Create new database from SQL Script

Just like with the tool above, there's a tool to run a script called [RunScript](https://h2database.com/javadoc/org/h2/tools/RunScript.html) that we will use to create a new database from `backup.sql`:

``` sh
# For a set of all possible options, run with -help
java -cp h2-v2.jar org.h2.tools.RunScript -url "jdbc:h2:file:path/to/database/h2-v2.db" -script backup.sql
```

This should create a new H2 database as `h2-v2.db`. At this point, change your application to use this database, if everything works well, then you can delete the old one and rename the new one.

Enjoy!
