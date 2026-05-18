class Sshpilot < Formula
  include Language::Python::Virtualenv

  desc "SSH connection manager and terminal with GTK4/libadwaita UI"
  homepage "https://github.com/mfat/sshpilot"
  url "https://github.com/mfat/sshpilot/archive/refs/tags/v4.7.9.tar.gz"
  sha256 "615db3165ddb5dffa39b9bc9ba0ac7faa5d5fff40664cb03f738fff77d9a369c"
  license "GPL-3.0-only"
  head "https://github.com/mfat/sshpilot.git", branch: "main"

  depends_on "pkg-config" => :build

  depends_on "adwaita-icon-theme"
  depends_on "gobject-introspection"
  depends_on "gtk4"
  depends_on "gtksourceview5"
  depends_on "libadwaita"
  depends_on "py3cairo"
  depends_on "pygobject3"
  depends_on "python@3.13"
  depends_on "sshpass"
  depends_on "vte3"

  # NOTE (formula draft): pyproject.toml declares
  #   PyGObject, pycairo, paramiko, cryptography, keyring, psutil.
  # PyGObject + pycairo come from the keg-only `pygobject3` +
  # `py3cairo` formulas above and are bridged into the virtualenv
  # via a .pth file in `install` rather than reinstalled through
  # pip — building them inside the venv requires the full GTK
  # toolchain and is redundant once the formula-level bindings
  # are present.
  #
  # The remaining four (paramiko, cryptography, keyring, psutil) +
  # their transitive deps install from PyPI at brew-install time.
  # Before this formula is offered as a homebrew-core PR the
  # resources should be pinned via explicit `resource` blocks
  # (`brew update-python-resources sshpilot` generates them).
  # Online-resolved deps work for a custom-tap / raw-URL install.

  def install
    venv = virtualenv_create(libexec, "python3.13")

    # Install sshpilot's runtime deps from PyPI first (so the venv
    # has paramiko / cryptography / keyring / psutil in scope when
    # the package itself imports them at runtime).
    system libexec/"bin/pip", "install", "-v",
           "paramiko>=3.4",
           "cryptography>=42.0",
           "keyring>=24.3",
           "psutil>=5.9.0"

    # Install the sshpilot package itself with --no-deps so pip
    # doesn't reinstall the GTK bindings; the .pth shim below
    # bridges the formula-installed pygobject3 + py3cairo.
    system libexec/"bin/pip", "install", "-v",
           "--no-deps", "--ignore-installed", buildpath

    # Wire PyGObject + pycairo from their formula installs into the
    # virtualenv's import path so the runtime can resolve `gi` +
    # `cairo`. Both formulas install into their own opt_libexec
    # site-packages; bridging via .pth keeps the virtualenv isolated
    # for the pip-installed deps while picking up the native bindings.
    site_packages = libexec/"lib/python3.13/site-packages"
    pygobject_path = Formula["pygobject3"].opt_libexec/"lib/python3.13/site-packages"
    pycairo_path = Formula["py3cairo"].opt_libexec/"lib/python3.13/site-packages"
    (site_packages/"homebrew-gtk.pth").write <<~PTH
      #{pygobject_path}
      #{pycairo_path}
    PTH

    # Copy the operator-facing assets the runtime expects under
    # `<prefix>/share/sshpilot`.
    if File.exist?(buildpath/"sshpilot.gresource")
      pkgshare.install "sshpilot.gresource"
    end
    pkgshare.install "io.github.mfat.sshpilot.desktop"
    pkgshare.install "io.github.mfat.sshpilot.metainfo.xml"

    # Stage run.py inside libexec so the bin/ shim has a stable
    # invocation target; pip installed the sshpilot package itself,
    # but run.py is the operator-facing entry that adjusts sys.path
    # defensively before importing.
    libexec.install "run.py"

    # Shim that activates the virtualenv + invokes run.py with the
    # GI typelib + XDG share paths Homebrew installs them at.
    (bin/"sshpilot").write <<~SHIM
      #!/bin/bash
      export GI_TYPELIB_PATH="#{HOMEBREW_PREFIX}/lib/girepository-1.0${GI_TYPELIB_PATH:+:${GI_TYPELIB_PATH}}"
      export XDG_DATA_DIRS="#{HOMEBREW_PREFIX}/share${XDG_DATA_DIRS:+:${XDG_DATA_DIRS}}"
      exec "#{libexec}/bin/python" "#{libexec}/run.py" "$@"
    SHIM
    chmod 0755, bin/"sshpilot"
  end

  def caveats
    <<~EOS
      sshPilot is a GTK4 / libadwaita application. The GUI requires a
      desktop session with the GTK runtime in scope:

        - macOS: launch from a terminal inside an active desktop
          login; XQuartz is not used (GTK4 ships with native macOS
          rendering).
        - Linux (Linuxbrew): a host display server (Wayland or X11) +
          dbus session must be available.

      The application stores its config under XDG_CONFIG_HOME/sshpilot
      and connection passwords in the platform keyring (macOS Keychain
      via the `keyring` package; Linux Secret Service via SecretStorage).
    EOS
  end

  test do
    # Smoke test: the shim executes, Python resolves the sshpilot
    # package, and the runtime exits when handed --help (or fails
    # gracefully on missing display — that path is still a success
    # signal because it proves the import + main entry are reachable).
    output = shell_output("#{bin}/sshpilot --help 2>&1", 0)
    assert_match(/sshpilot|usage|--help/i, output)
  end
end
