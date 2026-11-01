class MdViewer < Formula
  desc "Preview Markdown files clicked in Rex terminal panes"
  homepage "https://github.com/good-banana/rexworks/tree/main/md-viewer"
  url "https://github.com/good-banana/rexworks/archive/refs/tags/md-viewer-v0.1.1.tar.gz"
  sha256 "492524f703d7c48ec3b6f58fb4fc91933e456c79dc4cbc6ced1423cc67a34a6d"

  depends_on macos: :sonoma

  def install
    swift_major = Utils.safe_popen_read("swift", "--version")[/Swift version (\d+)/, 1].to_i
    if swift_major < 6
      odie "md-viewer needs Swift 6 or later. Install Xcode 16 or later Command Line Tools: xcode-select --install"
    end
    cd "md-viewer" do
      system "swift", "build", "--disable-sandbox", "-c", "release"
      bin.install ".build/release/md-viewer"
      libexec.install ".build/release/md-viewer_MDViewerWeb.bundle"
      system "scripts/build-app.sh", ".build/release/MDViewerHandler", version.to_s, libexec
    end
  end

  def caveats
    <<~EOS
      Make md-viewer the handler for Markdown files clicked in Rex:
        md-viewer setup
      Opens from other apps go to your previous Markdown app.
      After brew upgrade md-viewer, rerun md-viewer setup to update the installed app.
      To undo: md-viewer uninstall
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/md-viewer --help")
  end
end
