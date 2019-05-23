# salesforce-bugs
Demonstrate potential bugs in Salesforce for reference when reporting issues to
Salesforce Support.


## Inconsistent result for Url.getOrgDomainUrl()

Url.getOrgDomainUrl() normally returns a URL that starts with `https://`,
this can be verified by executing the following anonymous apex:

```
// File: anon.apex
System.assert(Url.getOrgDomainUrl().toExternalForm().startsWith('https://'));
```

```
$ sfdx force:apex:execute -f anon.apex
Compiled successfully.
Executed successfully.

45.0 APEX_CODE,DEBUG;APEX_PROFILING,INFO
Execute Anonymous: System.assert(Url.getOrgDomainUrl().toExternalForm().startsWith('https://'));
12:12:06.32 (32609545)|USER_INFO|[EXTERNAL]|00530000003Zbzs|alan.morey@example.net.sandbox|(GMT-07:00) Pacific Daylight Time (America/Los_Angeles)|GMT-07:00
12:12:06.32 (32643024)|EXECUTION_STARTED
12:12:06.32 (32649209)|CODE_UNIT_STARTED|[EXTERNAL]|execute_anonymous_apex
12:12:06.43 (43006963)|CUMULATIVE_LIMIT_USAGE
12:12:06.43 (43006963)|LIMIT_USAGE_FOR_NS|(default)|
  Number of SOQL queries: 0 out of 100
  Number of query rows: 0 out of 50000
  Number of SOSL queries: 0 out of 20
  Number of DML statements: 0 out of 150
  Number of DML rows: 0 out of 10000
  Maximum CPU time: 0 out of 10000
  Maximum heap size: 0 out of 6000000
  Number of callouts: 0 out of 100
  Number of Email Invocations: 0 out of 10
  Number of future calls: 0 out of 50
  Number of queueable jobs added to the queue: 0 out of 50
  Number of Mobile Apex push calls: 0 out of 10

12:12:06.43 (43006963)|CUMULATIVE_LIMIT_USAGE_END

12:12:06.32 (43071914)|CODE_UNIT_FINISHED|execute_anonymous_apex
12:12:06.32 (45604037)|EXECUTION_FINISHED
```

The same assertion will pass when run as a test.

```
$ sfdx force:source:deploy -p classes/UrlTest.cls \
    && sfdx force:apex:test:run -t UrlTest -w 5

=== Deployed Source
FULL NAME  TYPE       PROJECT PATH
─────────  ─────────  ────────────────────────────────────
UrlTest    ApexClass  url-bug/classes/UrlTest.cls
UrlTest    ApexClass  url-bug/classes/UrlTest.cls-meta.xml

=== Test Results
TEST NAME                                        OUTCOME  MESSAGE  RUNTIME (MS)
───────────────────────────────────────────────  ───────  ───────  ────────────
UrlTest.urlGetOrgDomainUrl_shouldReturnHttpsUrl  Pass              12

=== Test Summary
NAME                 VALUE
───────────────────  ──────────────────────────────────────────────────
Outcome              Passed
Tests Ran            1
Passing              1
Failing              0
Skipped              0
Pass Rate            100%
Fail Rate            0%
Test Start Time      May 23, 2019 12:21 PM
Test Execution Time  12 ms
Test Total Time      12 ms
Command Time         6316 ms
Hostname             https://example--sandbox.cs59.my.salesforce.com
Org Id               00D2C00000012AeUAI
Username             alan.morey@example.net.sandbox
Test Run Id          7072C0000115hiF
User Id              00530000003ZbzsAAC
```

However, when the test is part of a metadata deployment and the test is
executed in the context of the of the deployment, then the assertion will fail
because the result returned starts with `http://` instead of expected `https://`.

```
$ sfdx force:mdapi:deploy -c -d . -l RunSpecifiedTests -r UrlTest -w -1
1198 bytes written to /tmp/..zip using 88.795ms
Deploying /tmp/..zip...

=== Status
Status:  InProgress
jobid:  0Af2C00000SMP81SAH
Component errors:  0
Components checked:  1
Components total:  1
Tests errors:  0
Tests completed:  0
Tests total:  0
Check only: true


Deployment finished in 162000ms

=== Result
Status:  Failed
jobid:  0Af2C00000SMP81SAH
Completed:  2019-05-23T19:26:55.000Z
Component errors:  0
Components checked:  1
Components total:  1
Tests errors:  1
Tests completed:  0
Tests total:  1
Check only: true

=== Test Failures [1]
NAME     METHOD                                   MESSAGE                                                                                                                                     STACKTRACE
───────  ───────────────────────────────────────  ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────  ────────────────────────────────────────────────────────────────────────
UrlTest  urlGetOrgDomainUrl_shouldReturnHttpsUrl  System.AssertException: Assertion Failed: Expected OrgDomainUrl <http://example--sandbox.cs59.my.salesforce.com> to start with  https://  Class.UrlTest.urlGetOrgDomainUrl_shouldReturnHttpsUrl: line 16, column 1

Total Test Time:  208.0
```
