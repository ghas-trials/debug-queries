## Example ##

```yaml
name: "CodeQL"

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  schedule:
    - cron: '44 15 * * 6'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'java' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}
        debug: true
        packs: ghas-trials/java-debug-queries

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
```

Output (excerpt):
`2022-07-23T15:54:09.4594693Z Query 'Use of implicit PendingIntents' (java/android/implicit-pendingintents-debug) produced the following diagnostic messages:
2022-07-23T15:54:09.4595307Z   * Note: "XSS::XssVulnerableWriterSourceToWritingMethodFlowConfig": 0 sources, 531 sinks
2022-07-23T15:54:09.4595899Z   * Note: "ImplicitPendingIntentStartConf": 0 sources, 0 sinks
2022-07-23T15:54:09.4596194Z 
2022-07-23T15:54:09.4596743Z Query 'Leaking sensitive information through an implicit Intent' (java/android/sensitive-communication-debug) produced the following diagnostic messages:
2022-07-23T15:54:09.4597405Z   * Note: "XSS::XssVulnerableWriterSourceToWritingMethodFlowConfig": 0 sources, 531 sinks
2022-07-23T15:54:09.4597942Z   * Note: "Sensitive Communication Configuration": 0 sources, 0 sinks
2022-07-23T15:54:09.4598227Z 
2022-07-23T15:54:09.4598693Z Query 'Android Intent redirection' (java/android/intent-redirection-debug) produced the following diagnostic messages:
2022-07-23T15:54:09.4599293Z   * Note: "XSS::XssVulnerableWriterSourceToWritingMethodFlowConfig": 0 sources, 531 sinks
2022-07-23T15:54:09.4599831Z   * Note: "TaintedIntentComponentConf": 6 sources, 0 sinks
2022-07-23T15:54:09.4600285Z   * Note: "IntentRedirectionConfiguration": 6 sources, 0 sinks
2022-07-23T15:54:09.4600763Z   * Note: "SameIntentBeingRelaunchedConfiguration": 6 sources, 0 sinks
2022-07-23T15:54:09.4601074Z 
2022-07-23T15:54:09.4601526Z Query 'List of external dependencies' (java/dependencies-debug) produced the following diagnostic messages:
2022-07-23T15:54:09.4602074Z   * Note: 5798  junit-jupiter-api-5.6.2
2022-07-23T15:54:09.4602538Z   * Note: 0170  junit-jupiter-params-5.6.2
2022-07-23T15:54:09.4602957Z   * Note: 0110  mockito-core-3.4.6
2022-07-23T15:54:09.4603365Z   * Note: 0007  commons-lang3-3.11
2022-07-23T15:54:09.4603748Z   * Note: 0002  junit-pioneer-0.8.0
2022-07-23T15:54:09.4604137Z   * Note: 0002  jimfs-1.1
2022-07-23T15:54:09.4604541Z   * Note: 0000  opentest4j-1.2.0
2022-07-23T15:54:09.4604987Z   * Note: 0000  junit-platform-commons-1.6.2
2022-07-23T15:54:09.4605394Z   * Note: 0000  guava-18.0
2022-07-23T15:54:09.4605798Z   * Note: 0000  apiguardian-api-1.1.0``
```
