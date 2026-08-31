# Rails 19.0 acceptance

## Source decision

Rails 19.0 uses Debian 13 Trixie packages for Ruby 3.3, Rails 7.2,
Phusion Passenger 6, Apache, MariaDB and Node.js 20. The sample application's
Bundler lock is generated with `bundle lock --local`, so the shipped stack does
not download application gems or language runtimes from upstream. Webmin and
its Apache and MariaDB modules continue to come from the signed TurnKey Trixie
repository.

The v18 common Rails build cloned rbenv and ruby-build and then installed the
latest available Ruby and gems. Trixie now supplies the complete documented
stack, so v19 replaces that changing upstream build with Debian packages.

## Acceptance command

```sh
/sandboxed-git/turnkey/tools/test-v19-appliance rails \
    --source /home/agent/.local/worktrees/turnkey-apps/rails/wish-rails-v19-trixie
```

The assigned `bin/turnkey-v19-test` path was not present in the shared harness
checkout. `tools/test-v19-appliance` is the established v19 runner and retains
the source revision, build evidence, configured root, child result, updater
result, cleanup status and verdict.

## README crosswalk

| README contract | Focused check | Required result |
| --- | --- | --- |
| Rails sample application at `/var/www/railsapp` | Request the HTTP entry path and HTTPS through Apache, then inspect the response | Both paths reach the production app; the page identifies TurnKey Rails |
| Ruby 3.3 and Rails 7.2 come from Debian | Query commands, packages and binary ownership | Versions match the Trixie packages and `/usr/local/rbenv` is absent |
| Apache Passenger deployment | Inspect loaded modules and response headers after requesting the application | Apache loads Passenger and the application response identifies Passenger |
| MariaDB production, development and test databases | Check all database names, then write, read and delete a temporary production row through Rails as `www-data` | All three databases exist and the application roundtrip succeeds |
| First boot regenerates application credentials | Check the normal inithook result, credential files, ownership and production database access | Credential files are nonempty and protected for `root:www-data`; the regenerated database password works through Rails |
| Webmin provides the documented administration surface | Check the landing-page link, HTTPS endpoint and Webmin Apache and MariaDB modules | The link points to port 12321, HTTPS responds and both modules are installed |
| Node.js 20 and build tools support development | Query the Debian Node.js package and runtime | The installed runtime reports major version 20 |
| APT maintains the packaged stack | Refresh metadata and inspect candidates for identity-defining packages | Signed Trixie metadata is accepted, every package has a candidate and installed versions remain unchanged |
| Root Webmin and SSH credentials are inherited from Core | Cite the unchanged Core layer | Core 19 baseline passed at source `24c82ee3540ce545422742b0e28ba6b687c53ec2` |

## Updater check

`tests/v19.sh` runs `apt-get update` and checks candidates for `rails`, `ruby`,
`libapache2-mod-passenger`, `mariadb-server`, `apache2` and `nodejs`. It proves
the refresh does not mutate installed versions and that no Bookworm source
remains. The sample application runs `bundle check` against its locally
resolved lock file.

## Accepted run

Run `20260824t101906z-4198-31522` passed on 2026-08-24 from source commit
`61748a401248aa63a231a117f0a79fee9622ce85` with harness commit
`b6f8b8c2f3e8f00fd5cf36869e645fc08f01f87e`. The report is retained at:

```text
/home/agent/.local/state/turnkey-v19-harness/runs/rails/20260824t101906z-4198-31522/report.txt
```

The report SHA-256 is
`3b49b35f69d0b607b14bc17dd069035eb5cf617bee944c7b8ffa95f41f88b77f`.
The build, image import, normal boot, runtime tests and cleanup all passed. The
runtime result records Rails 7.2.2.2, Ruby 3.3.8, Passenger 6.0.26, MariaDB
11.8.6, Apache 2.4.68 and Node.js 20.19.2. It also records successful HTTP and
HTTPS application requests, Webmin access, the Rails database roundtrip,
credential regeneration and the APT updater check.

This accepted source commit contains all appliance and executable test changes.
The following commit records this run in the documentation only, so another
rootfs build is not required for that evidence-only change.

## Known limitation

Docker acceptance does not exercise the installer, kernel, bootloader or
physical hardware. Rails adds no behavior at those boundaries, so the accepted
Core 19 baseline supplies that inherited evidence.

## Deferred minor issues

- Running Rails commands explicitly as `www-data` prints a Bundler warning
  because `/var/www` is not writable and Bundler uses a temporary home. The
  production application and database roundtrip pass. Normal development
  commands run as `root`, so this is not prioritized for v19.0.
- `passenger-status` cannot open its administrative socket when the harness
  creates a path longer than the Linux Unix-socket limit. The accepted test
  instead proves Passenger through the loaded Apache module, successful
  application responses and Passenger response header. Normal appliance paths
  are shorter, so no appliance change is planned.
