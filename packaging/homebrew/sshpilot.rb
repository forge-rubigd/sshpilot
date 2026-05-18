class Sshpilot < Formula
  include Language::Python::Virtualenv

  desc "SSH connection manager and terminal with GTK4/libadwaita UI"
  homepage "https://github.com/mfat/sshpilot"
  url "https://github.com/mfat/sshpilot/archive/refs/tags/v4.7.9.tar.gz"
  sha256 "615db3165ddb5dffa39b9bc9ba0ac7faa5d5fff40664cb03f738fff77d9a369c"
  license "GPL-3.0-only"
  head "https://github.com/mfat/sshpilot.git", branch: "main"

  depends_on "pkg-config" => :build
  # bcrypt 5.x + cryptography 35+ build their low-level crypto via
  # Rust (maturin / setuptools-rust). Build-only dep — no runtime
  # Rust needed once the sdists are compiled into wheels inside
  # the virtualenv. Standard Homebrew pattern for Python-with-Rust
  # resources.
  depends_on "rust" => :build

  depends_on "adwaita-icon-theme"
  depends_on "gobject-introspection"
  depends_on "gtk4"
  depends_on "gtksourceview5"
  depends_on "libadwaita"
  # PyNaCl pins its own libsodium copy inside its sdist; without
  # this system dep + SODIUM_INSTALL=system below the wheel build
  # fails on missing sodium.h. Standard Homebrew pattern for any
  # formula carrying PyNaCl as a transitive resource.
  depends_on "libsodium"
  depends_on "py3cairo"
  depends_on "pygobject3"
  depends_on "python@3.13"
  depends_on "sshpass"
  depends_on "vte3"

  # Python runtime deps from pyproject.toml + their transitive
  # deps, pinned for `virtualenv_install_with_resources`.
  # PyGObject + pycairo come from the keg-only `pygobject3` +
  # `py3cairo` formulas and are bridged into the virtualenv via
  # a .pth shim in `install` — building them inside the venv
  # requires the full GTK toolchain and is redundant once the
  # formula-level bindings are present.

  resource "bcrypt" do
    url "https://files.pythonhosted.org/packages/d4/36/3329e2518d70ad8e2e5817d5a4cac6bba05a47767ec416c7d020a965f408/bcrypt-5.0.0.tar.gz"
    sha256 "f748f7c2d6fd375cc93d3fba7ef4a9e3a092421b8dbf34d8d4dc06be9492dfdd"
  end

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/eb/56/b1ba7935a17738ae8453301356628e8147c79dbb825bcbc73dc7401f9846/cffi-2.0.0.tar.gz"
    sha256 "44d1b5909021139fe36001ae048dbdde8214afa20200eda0f64c068cac5d5529"
  end

  resource "cryptography" do
    url "https://files.pythonhosted.org/packages/9f/a9/db8f313fdcd85d767d4973515e1db101f9c71f95fced83233de224673757/cryptography-48.0.0.tar.gz"
    sha256 "5c3932f4436d1cccb036cb0eaef46e6e2db91035166f1ad6505c3c9d5a635920"
  end

  resource "importlib_metadata" do
    url "https://files.pythonhosted.org/packages/a9/01/15bb152d77b21318514a96f43af312635eb2500c96b55398d020c93d86ea/importlib_metadata-9.0.0.tar.gz"
    sha256 "a4f57ab599e6a2e3016d7595cfd72eb4661a5106e787a95bcc90c7105b831efc"
  end

  resource "jaraco.classes" do
    url "https://files.pythonhosted.org/packages/06/c0/ed4a27bc5571b99e3cff68f8a9fa5b56ff7df1c2251cc715a652ddd26402/jaraco.classes-3.4.0.tar.gz"
    sha256 "47a024b51d0239c0dd8c8540c6c7f484be3b8fcf0b2d85c13825780d3b3f3acd"
  end

  resource "jaraco.context" do
    url "https://files.pythonhosted.org/packages/af/50/4763cd07e722bb6285316d390a164bc7e479db9d90daa769f22578f698b4/jaraco_context-6.1.2.tar.gz"
    sha256 "f1a6c9d391e661cc5b8d39861ff077a7dc24dc23833ccee564b234b81c82dfe3"
  end

  resource "jaraco.functools" do
    url "https://files.pythonhosted.org/packages/36/cf/ea4ef2920830dea3f5ab2ea4da6fb67724e6dca80ee2553788c3607243d0/jaraco_functools-4.5.0.tar.gz"
    sha256 "3bb5665ea4a020cf78a7040e89154c77edadb3ca74f366479669c5999aa70b03"
  end

  resource "jeepney" do
    url "https://files.pythonhosted.org/packages/7b/6f/357efd7602486741aa73ffc0617fb310a29b588ed0fd69c2399acbb85b0c/jeepney-0.9.0.tar.gz"
    sha256 "cf0e9e845622b81e4a28df94c40345400256ec608d0e55bb8a3feaa9163f5732"
  end

  resource "keyring" do
    url "https://files.pythonhosted.org/packages/43/4b/674af6ef2f97d56f0ab5153bf0bfa28ccb6c3ed4d1babf4305449668807b/keyring-25.7.0.tar.gz"
    sha256 "fe01bd85eb3f8fb3dd0405defdeac9a5b4f6f0439edbb3149577f244a2e8245b"
  end

  resource "more-itertools" do
    url "https://files.pythonhosted.org/packages/a2/f7/139d22fef48ac78127d18e01d80cf1be40236ae489769d17f35c3d425293/more_itertools-11.0.2.tar.gz"
    sha256 "392a9e1e362cbc106a2457d37cabf9b36e5e12efd4ebff1654630e76597df804"
  end

  resource "paramiko" do
    url "https://files.pythonhosted.org/packages/62/93/dcc25d52f49022ae6175d15e6bd751f1acc99b98bc61fc55e5155a7be2e7/paramiko-5.0.0.tar.gz"
    sha256 "36763b5b95c2a0dcfdf1abc48e48156ee425b21efe2f0e787c2dd5a95c0e5e79"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
    sha256 "0746f5f8d406af344fd547f1c8daa5f5c33dbc293bb8d6a16d80b4bb88f59372"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/1b/7d/92392ff7815c21062bea51aa7b87d45576f649f16458d78b7cf94b9ab2e6/pycparser-3.0.tar.gz"
    sha256 "600f49d217304a5902ac3c37e1281c9fe94e4d0489de643a9504c5cdfdfc6b29"
  end

  resource "PyNaCl" do
    url "https://files.pythonhosted.org/packages/d9/9a/4019b524b03a13438637b11538c82781a5eda427394380381af8f04f467a/pynacl-1.6.2.tar.gz"
    sha256 "018494d6d696ae03c7e656e5e74cdfd8ea1326962cc401bcf018f1ed8436811c"
  end

  resource "SecretStorage" do
    url "https://files.pythonhosted.org/packages/1c/03/e834bcd866f2f8a49a85eaff47340affa3bfa391ee9912a952a1faa68c7b/secretstorage-3.5.0.tar.gz"
    sha256 "f04b8e4689cbce351744d5537bf6b1329c6fc68f91fa666f60a380edddcd11be"
  end

  resource "zipp" do
    url "https://files.pythonhosted.org/packages/30/21/093488dfc7cc8964ded15ab726fad40f25fd3d788fd741cc1c5a17d78ee8/zipp-3.23.1.tar.gz"
    sha256 "32120e378d32cd9714ad503c1d024619063ec28aad2248dc6672ad13edfa5110"
  end

  resource "backports.tarfile" do
    url "https://files.pythonhosted.org/packages/86/72/cd9b395f25e290e633655a100af28cb253e4393396264a98bd5f5951d50f/backports_tarfile-1.2.0.tar.gz"
    sha256 "d75e02c268746e1b8144c278978b6e98e85de6ad16f8e4b0844a154557eca991"
  end

  def install
    # PyNaCl's wheel build invokes its bundled libsodium copy
    # unless told otherwise. SODIUM_INSTALL=system points it at
    # the Homebrew-installed libsodium headers / lib so the build
    # links against the shared system copy instead of trying to
    # compile the bundled tarball.
    ENV["SODIUM_INSTALL"] = "system"

    # virtualenv_install_with_resources creates the venv, installs
    # every `resource` block above, then installs the package
    # itself. Replaces the manual `system pip` calls from the
    # initial draft that hit the without-pip venv failure.
    virtualenv_install_with_resources

    # Bridge PyGObject + pycairo from their formula installs into
    # the virtualenv's import path so the runtime can resolve `gi`
    # + `cairo`. Both formulas install into their own opt_libexec
    # site-packages; .pth keeps the virtualenv isolated for the
    # pip-installed deps while picking up the native bindings.
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
