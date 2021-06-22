Ansible Playbook for installing DeDRM for Calibre under Wine
============================================================

## Obligatory notice

Only use this to backup the books you own, etc.

## Why write this?

I kept having issues migrating over my Calibre +
[DeDRM](https://github.com/apprenticeharper/DeDRM_tools/)
configuration from one computer to another, and got sick of manually
repeating all the steps.  Furthermore, writing this let me brush up on
my Ansible skills.

Whilst doing this I also came across several issues (that might be due
to my own setup) and found how to deal with them.

### What does it do?

This Ansible playbook will automate:

1. Creating the Wine Prefix for use.
2. Installing all necessary Windows dependencies in Wine (Python,
   Kindle, Adobe Digital Editions, etc.).
3. Install and configure the plugin in Calibre.

### Dependencies

The canonical list of Windows dependencies as required for NixOS 20.09
can be found in [shell.nix][].  Package names for other Linux
distributions will vary.

[shell.nix]: shell.nix

In particular, you will need to use a version of Calibre using
Python-2 (so before version 5).

### So can I run this unattended?

Unfortunately, no.  Depending on how you
[configure](configuration.yml) this, you will need to:

1. Do the typical Windows thing of clicking "Next" in Windows
   installation dialogues.
2. Sign-in/authorize Kindle and Adobe Digital Editions so that the key
   can be extracted.

## How to use this

First of all, edit the [configuration](configuration.yml) to what you
require; possible options include:

1. Change DeDRM version (at time of writing, only 6.7.0+ will work due
   to the change in code structure).
2. Changing the name of the Wine Prefix (you should ensure that the
   directory doesn't exist before running this).
3. Disabling Kindle or Adobe Digital Editions support.

You may then need to run (especially if using Ansible 2.10 or newer):


```sh
ansible-galaxy install -r requirements.yml
```

Afterwards, you can just do:

```sh
ansible-playbook install.yml
```

If you ever need to uninstall:

```sh
ansible-playbook uninstall.yml
```

### Upgrading DeDRM

If you wish to change the version of DeDRM:

1. Make sure Calibre isn't running.
2. Run `ansible-playbook remove-plugin.yml` to remove the current
   version of DeDRM.
3. Change the version in [configuration.yml]
4. Run `ansible-playbook install.yml` again.

### What other changes can be made?

If you started with either `install_kindle` or `install_adobe` set to
`false` then you can change them to `true` and re-install and it
should work.

However, you can't _remove_ one of these integrations without uninstalling.

## NixOS / nixpkgs

If using NixOS or nixpkgs, then you should first run `nix-shell
--pure` in this directory to ensure that you get the required
dependencies installed, especially since Ansible doesn't work when
installed at the top-level.  This was tested with Nixpkgs version
`20.09.4321.115dbbe82eb`.

Note that as of 20.09, the `calibre` package uses Python 3; as such,
be sure to use `calibre-py2` for both the the system/user level
(however you have installed Calibre as a user) and in [shell.nix][].

Furthermore, for the plugin to run, it seems to need to have PyCrypto
installed on the Linux side as well as within Wine.  However, PyCrypto
has been [deprecated](https://github.com/NixOS/nixpkgs/issues/21671)
in nixpkgs and the replacement PyCryptodome [doesn't work with
DeDRM](https://github.com/apprenticeharper/DeDRM_tools/issues/1306).

As such, you may need something like this:

```nix
  nixpkgs.overlays = [
    (self: super: rec {
      pycrypto-original = super.python27.pkgs.buildPythonPackage rec {
        pname = "pycrypto-original";
        version = "2.6.1";
        src = super.python27.pkgs.fetchPypi {
          inherit pname version;
          sha256 = "0g0ayql5b9mkjam8hym6zyg6bv77lbh66rv1fyvgqb17kfc1xkpj";
        };

        patches = [
          (super.fetchpatch {
            name = "CVE-2013-7459.patch";
            url = "https://anonscm.debian.org/cgit/collab-maint/python-crypto.git/plain/debian/patches/CVE-2013-7459.patch?h=debian/2.6.1-7";
            sha256 = "01r7aghnchc1bpxgdv58qyi2085gh34bxini973xhy3ks7fq3ir9";
          })
        ];

        preConfigure = ''
          sed -i 's,/usr/include,/no-such-dir,' configure
          sed -i "s!,'/usr/include/'!!" setup.py
        '';

        buildInputs = super.stdenv.lib.optional (!super.python.isPypy or false) super.gmp; # optional for pypy

        doCheck = !(super.python.isPypy or super.stdenv.isDarwin); # error: AF_UNIX path too long

        meta = {
          homepage = "http://www.pycrypto.org/";
          description = "Python Cryptography Toolkit";
          platforms = super.stdenv.lib.platforms.unix;
        };
      };

      calibre = super.calibre.overrideAttrs (oldAttrs: rec {
        # For DeDRM plugin.
        buildInputs = oldAttrs.buildInputs ++ [ self.pycrypto-original ];
      });
    })
  ];
```

(This is _not_ configured to run within nix-shell as it wasn't
intended to be how you run Calibre.  You can always modify it though.)

## Licensing

This Ansible code is available under the [MIT License](LICENSE).

It includes [code](library/json_patch.py) by Joey Espinosa licensed
under the MIT License from
https://github.com/particledecay/ansible-jsonpatch
