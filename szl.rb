class Szl < Formula
  desc "Google's Sawzall language for statistical aggregation of log data."
  homepage "https://bitbucket.org/aecolley/szl"
  url "https://bitbucket.org/aecolley/szl/downloads/szl-1.0.1.tar.gz"
  sha256 "791ff01fbf72fb3ad0c4e49a8de40dc3d7822fe549ee94d11ea7226557c0e013"

  head do
    url "https://bitbucket.org/aecolley/szl", :using => :hg
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "icu4c"
  depends_on "pcre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  # We don't need gobjdump for core functionality, but only for
  # "szl --print_code --native". We can use it if it's installed later.
  depends_on "binutils" => :optional

  def install
    ENV.cxx11
    system "autoreconf", "-fvi" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug",
                          "--disable-rpath",
                          "--prefix=#{prefix}",
                          "OBJDUMP=#{Formula["binutils"].opt_bin}/gobjdump"
    system "make", "install"
  end

  test do
    require "open3"
    args = [
      '--e=
        t: table sum of int;
        if (match("<[Pp]>", string(input)))
          emit t <- 1;',
      "--table_output=t",
      "#{doc}/sawzall-spec.html",
    ]
    output, status = Open3.capture2("#{bin}/szl", *args)
    assert_equal 0, status
    assert_equal "t[] = 30\n", output
  end
end
