class Qt6Svg < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.4/6.4.0/submodules/qtsvg-everywhere-src-6.4.0.tar.xz"
  sha256 "03fdae9437d074dcfa387dc1f2c6e7e14fea0f989bf7e1aa265fd35ffc2c5b25"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]
  head "https://code.qt.io/qt/qt6.git", branch: "dev"

  # The first-party website doesn't make version information readily available,
  # so we check the `head` repository tags instead.
  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_ventura:  "fd2fb8ecbe90be5f23e028264a6de270c3945dd10011f5622f3d81e84e8c8cb1"
    sha256 cellar: :any, arm64_monterey: "009a797cab75f61c56ed9764219a60ebc4ba4359ec9dfb30104c6efd74c34dfb"
    sha256 cellar: :any, arm64_big_sur:  "acea0b4f290b0ff85c732201606326d27e0340691921bad831abeb68741aed45"
    sha256 cellar: :any, monterey:       "084544813d9eb375ed68a385e1b3e0514b07f6ad9c27c66879c75aa712af6fe6"
    sha256 cellar: :any, big_sur:        "979c2b9c8b5882f16a43147b978914d98519d6103d89888bdc212e09dda4ab8c"
    sha256 cellar: :any, catalina:       "7f74703923f0f74fd9cef086bd87726ca2cd0b3b62fe8486133f99257051ad82"
  end

  depends_on "cmake"      => [:build, :test]
  depends_on "ninja"      => :build
  depends_on "pkg-config" => :build
  depends_on "six" => :build
  depends_on xcode: :build

  depends_on "qt6-base"
  depends_on "assimp"
  depends_on "brotli"
  depends_on "dbus"
  depends_on "double-conversion"
  depends_on "freetype"
  depends_on "glib"
  depends_on "icu4c"
  depends_on "jasper"
  depends_on "jpeg-turbo"
  depends_on "libb2"
  depends_on "libmng"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "md4c"
  depends_on "openssl@1.1"
  depends_on "pcre2"
  depends_on "sqlite"
  depends_on "zstd"

  uses_from_macos "perl"  => :build
  uses_from_macos "llvm" => :test # Our test relies on `clang++` in `PATH`.

  uses_from_macos "cups"
  uses_from_macos "krb5"
  uses_from_macos "libxslt"
  uses_from_macos "zlib"

  fails_with gcc: "5"

  def install
    cmake_args = std_cmake_args() 

    system "cmake", *cmake_args ,"."
    system "cmake", "--build", "."
    system "cmake", "--install", "."


    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    # Tracking issues:
    # https://bugreports.qt.io/browse/QTBUG-86080
    # https://gitlab.kitware.com/cmake/cmake/-/merge_requests/6363
    lib.glob("*.framework") do |f|
      # Some config scripts will only find Qt in a "Frameworks" folder
      frameworks.install_symlink f
      include.install_symlink f/"Headers" => f.stem
    end

    return unless OS.mac?

    bin.glob("*.app") do |app|
      libexec.install app
      bin.write_exec_script libexec/app.basename/"Contents/MacOS"/app.stem
    end
  end

end
