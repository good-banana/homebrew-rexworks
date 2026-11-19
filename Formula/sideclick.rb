class Sideclick < Formula
  desc "Cmd-click web links in Rex to open them in a browser pane beside you"
  homepage "https://github.com/good-banana/rexworks/tree/main/sideclick"
  url "https://github.com/good-banana/rexworks/archive/refs/tags/sideclick-v0.1.0.tar.gz"
  sha256 "dd6df31fd4214248a8fdcabd7ef952732f246005378f8cd3dd704d04b5963482"

  depends_on macos: :sonoma

  def install
    swift_major = Utils.safe_popen_read("swift", "--version")[/Swift version (\d+)/, 1].to_i
    if swift_major < 6
      odie "sideclick needs Swift 6 or later. Install Xcode 16 or later Command Line Tools: xcode-select --install"
    end
    cd "sideclick" do
      system "swift", "build", "--disable-sandbox", "-c", "release"
      bin.install ".build/release/sideclick"
      system "scripts/build-app.sh", ".build/release/SideclickHandler", version.to_s, libexec
    end
  end

  def caveats
    <<~EOS
      Make Cmd-clicked web links in Rex open in a browser pane:
        sideclick setup
      Setup checks for terminal-browser and offers to install it.
      Cmd+Option-click, and links from other apps, go to your previous browser.
      After brew upgrade sideclick, rerun sideclick setup to update the installed app.
      To undo: sideclick uninstall
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/sideclick --help")
    assert_match version.to_s, shell_output("#{bin}/sideclick --version")
  end
end
