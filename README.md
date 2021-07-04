Ansible Playbook for installing DeDRM for Calibre under Wine
============================================================

## Obligatory notice

Only use this to backup the books you own, etc.

## Upgrade warning

**ESPECIALLY IF YOU ARE GOING FROM PYTHON-2 TO PYTHON-3**

Please uninstall the existing version before installing the new
version (you can also use a new prefix for testing and not deleting
the old version in case something breaks; in this case, first
uninstall the Calibre plugin configuration first).

See below for more details.

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

The canonical list of Windows dependencies as required for NixOS 21.05
can be found in [shell.nix][].  Package names for other Linux
distributions will vary.

[shell.nix]: shell.nix

This supports Calibre >= 5 and DeDRM tools >= 7, both of which using
Python-3.

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

1. Change DeDRM version.
2. Changing the name of the Wine Prefix (you should ensure that the
   directory doesn't exist before running this).
3. Download directory.
4. Disabling Kindle or Adobe Digital Editions support.

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
`21.05.1076.bad3ccd099e`.

Note that this package requires
[PyCryptodome](https://www.pycryptodome.org/), which is not a
dependency of Calibre in Nixpkgs.  As such, you may need something
like this:

```nix
  nixpkgs.overlays = [
    (self: super: rec {
      calibre = super.calibre.overrideAttrs (oldAttrs: rec {
        # For DeDRM plugin
        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [ super.python3Packages.pycryptodome ];
      });
    })
  ];
```

(This seems to work via the `nix-shell` route, possibly due to Ansible
bringing in PyCryptodome already.)

## Licensing

This Ansible code is available under the [MIT License](LICENSE).

It includes [code](library/json_patch.py) by Joey Espinosa licensed
under the MIT License from
https://github.com/particledecay/ansible-jsonpatch
