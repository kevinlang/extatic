## mix extatic.new

Provides `extatic.new` installer as an archive.

To install from Hex, run:

    $ mix archive.install hex extatic_new

To build and install it locally,
ensure any previous archive versions are removed:

    $ mix archive.uninstall extatic_new

Then run, from this directory:

    $ MIX_ENV=prod mix do archive.build, archive.install
