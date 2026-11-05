class MdViewer < Formula
  desc "Preview Markdown files clicked in Rex terminal panes"
  homepage "https://github.com/good-banana/rexworks/tree/main/md-viewer"
  url "https://github.com/good-banana/rexworks/archive/refs/tags/md-viewer-v0.3.2.tar.gz"
  sha256 "90017188010ab1f6bb6786c8d3c25cd7208035e1463ee63041c2497a3ac9a3e6"

  depends_on macos: :sonoma

  resource "swift-cmark" do
    url "https://github.com/swiftlang/swift-cmark/archive/437611671145d47e6d9679761b8a5987766f4ae5.tar.gz"
    sha256 "bcc825cecd1710cdca28f7cc0a74423a691966be2f3a4c6fa8739a2009ed5bf2"
  end

  def install
    swift_major = Utils.safe_popen_read("swift", "--version")[/Swift version (\d+)/, 1].to_i
    if swift_major < 6
      odie "md-viewer needs Swift 6 or later. Install Xcode 16 or later Command Line Tools: xcode-select --install"
    end
    resource("swift-cmark").stage(buildpath/"swift-cmark")
    cd "md-viewer" do
      inreplace "Package.swift", '.package(url: "https://github.com/swiftlang/swift-cmark", revision: "437611671145d47e6d9679761b8a5987766f4ae5")', '.package(path: "../swift-cmark")'
      rm "Package.resolved"
      system "swift", "build", "--disable-sandbox", "-c", "release"
      bin.install ".build/release/md-viewer"
      libexec.install ".build/release/md-viewer_MDViewerRender.bundle"
      libexec.install ".build/release/md-viewer_MDViewerMermaid.bundle"
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
    assert_match version.to_s, shell_output("#{bin}/md-viewer --version")
  end
end
