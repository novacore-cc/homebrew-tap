cask "eri" do
  version "1.0.0"
  sha256 "14d394956ccee5e24a4520a7591ca83438ececfa154828affc79ade1dcb2a8b0"

  url "https://github.com/novacore-cc/eri/releases/download/v#{version}/Eri-#{version}.zip"
  name "Eri"
  desc "HTTP/HTTPS link router driven by a TOML config"
  homepage "https://github.com/novacore-cc/eri"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :monterey"

  app "Eri.app"

  zap trash: [
    "~/.config/eri",
    "~/Library/Application Support/Eri",
  ]
end
